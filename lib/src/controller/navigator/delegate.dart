import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/controller.dart';
import 'package:octopus/src/controller/delegate.dart';
import 'package:octopus/src/controller/guard.dart';
import 'package:octopus/src/controller/navigator/observer.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/controller/state_queue.dart';
import 'package:octopus/src/controller/typedefs.dart';
import 'package:octopus/src/state/node_extra_storage.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/util/logs.dart';
import 'package:octopus/src/util/state_util.dart';
import 'package:octopus/src/widget/dialog_page.dart';
import 'package:octopus/src/widget/inherited_octopus.dart';
import 'package:octopus/src/widget/navigator.dart';
import 'package:octopus/src/widget/no_animation.dart';

/// {@nodoc}
const String _kDialogNodeName = 'd';

/// Octopus delegate.
/// {@nodoc}
@internal
final class OctopusDelegate$NavigatorImpl extends OctopusDelegate
    with ChangeNotifier, _TitleMixin {
  /// Octopus delegate.
  /// {@nodoc}
  OctopusDelegate$NavigatorImpl({
    required OctopusRoute defaultRoute,
    required this.routes,
    required OctopusStateObserver$NavigatorImpl observer,
    List<IOctopusGuard>? guards,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    NotFoundBuilder? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  })  : _observer = observer,
        _defaultRoute = defaultRoute,
        _guards = guards?.toList(growable: false) ?? <IOctopusGuard>[],
        _restorationScopeId = restorationScopeId,
        _observers = observers,
        _transitionDelegate = transitionDelegate ??
            (kIsWeb
                ? const NoAnimationTransitionDelegate<Object?>()
                : const DefaultTransitionDelegate<Object?>()),
        _notFound = notFound,
        _onError = onError {
    // Subscribe to the guards.
    _guardsListener = Listenable.merge(_guards)..addListener(_onGuardsNotified);
    // Revalidate the initial state with the guards.
    _setConfiguration(observer.value);
    // Clear extra storage when processing completed.
    _$stateChangeQueue.addCompleteListener(_onIdleState);
    // Update title & color
    _updateTitle(routes[currentConfiguration.children.lastOrNull?.name]);
  }

  final OctopusStateObserver$NavigatorImpl _observer;

  /// {@nodoc}
  @Deprecated('Renamed to "observer".')
  OctopusStateObserver get stateObserver => _observer;

  /// State observer,
  /// which can be used to listen to changes in the [OctopusState].
  OctopusStateObserver get observer => _observer;

  /// Current configuration.
  @override
  OctopusState$Immutable get currentConfiguration => _observer.value;

  /// The restoration scope id for the navigator.
  final String? _restorationScopeId;

  /// Observers for the navigator.
  final List<NavigatorObserver>? _observers;

  /// Transition delegate.
  final TransitionDelegate<Object?> _transitionDelegate;

  /// Not found widget builder.
  final NotFoundBuilder? _notFound;

  /// Error handler.
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Current octopus instance.
  @internal
  late WeakReference<Octopus> $octopus;

  /// Routes hash table.
  @override
  final Map<String, OctopusRoute> routes;

  /// Default fallback route.
  final OctopusRoute _defaultRoute;

  /// Guards.
  final List<IOctopusGuard> _guards;
  late final Listenable _guardsListener;

  /// WidgetApp's navigator.
  NavigatorState? get navigator => _modalObserver.navigator;
  final NavigatorObserver _modalObserver = RouteObserver<ModalRoute<Object?>>();

  T _handleErrors<T>(
    T Function() callback, [
    T Function(Object error, StackTrace stackTrace)? fallback,
  ]) {
    try {
      return callback();
    } on Object catch (e, s) {
      _onError?.call(e, s);
      if (fallback == null) rethrow;
      return fallback(e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = buildPages(context, _observer.value.children);
    if (pages.isEmpty)
      pages.add(
        _defaultRoute.pageBuilder(
          context,
          currentConfiguration,
          _defaultRoute.node(),
        ),
      );
    return InheritedOctopus(
      octopus: $octopus.target!,
      state: _observer.value,
      child: OctopusNavigator(
        router: $octopus.target!,
        restorationScopeId: _restorationScopeId,
        reportsRouteUpdateToEngine: true,
        observers: <NavigatorObserver>[
          _modalObserver,
          ...?_observers,
        ],
        transitionDelegate: _transitionDelegate,
        pages: pages,
        onPopPage: _onPopPage,
        onUnknownRoute: (settings) => _onUnknownRoute(context, settings),
      ),
    );
  }

  bool _onPopPage(Route<Object?> route, Object? result) => _handleErrors(
        () {
          if (!route.didPop(result)) return false;
          {
            final state = _observer.value.mutate();
            if (state.children.isEmpty) return false;
            final node = state.children.removeLast();

            // If the node is a dialog, then save the result
            if (node.name == _kDialogNodeName) {
              final key = node.arguments['k'];
              if (key != null) {
                _dialogResults[key] = result;
              }
            }

            // Update the state
            setNewRoutePath(state);
          }
          return true;
        },
        (_, __) => false,
      );

  @override
  @internal
  List<Page<Object?>> buildPages(
          BuildContext context, List<OctopusNode> nodes) =>
      _handleErrors(
        () => measureSync(
          'buildPagesFromNodes',
          () {
            final pages = <Page<Object?>>[];
            // Build pages
            for (final node in nodes) {
              try {
                // If the node is a dialog, then build the dialog page
                if (node.name == _kDialogNodeName) {
                  final key = node.arguments['k'];
                  if (key == null) continue;
                  final page = _dialogBuilders[key];
                  if (page == null) continue;
                  pages.add(page);
                  continue;
                }
                // Build the page
                final Page<Object?> page;
                final route = routes[node.name];
                if (route == null) {
                  if (_notFound != null) {
                    page = MaterialPage(
                      child: _notFound.call(
                        context,
                        node.name,
                        node.arguments,
                      ),
                      arguments: node.arguments,
                    );
                  } else {
                    _onError?.call(
                      Exception('Unknown route ${node.name}'),
                      StackTrace.current,
                    );
                    continue;
                  }
                } else {
                  page = route.pageBuilder(context, currentConfiguration, node);
                }
                pages.add(page);
              } on Object catch (error, stackTrace) {
                developer.log(
                  'Failed to build page',
                  name: 'octopus',
                  error: error,
                  stackTrace: stackTrace,
                  level: 1000,
                );
                _onError?.call(error, stackTrace);
              }
            }
            if (pages.isNotEmpty) return pages;
            return <Page<Object?>>[];
          },
          arguments: kMeasureEnabled
              ? <String, String>{
                  'nodes': nodes.map<String>((e) => e.name).join(', ')
                }
              : null,
        ),
        (error, stackTrace) {
          developer.log(
            'Failed to build pages',
            name: 'octopus',
            error: error,
            stackTrace: stackTrace,
            level: 1000,
          );
          final flutterError = switch (error) {
            FlutterError error => error,
            String message => FlutterError(message),
            _ => FlutterError.fromParts(
                <DiagnosticsNode>[
                  ErrorSummary('Failed to build pages'),
                  ErrorDescription(Error.safeToString(error)),
                ],
              ),
          };
          return <Page<Object?>>[
            MaterialPage(
              child: Scaffold(
                body: SafeArea(
                  child: ErrorWidget.withDetails(
                    message: 'Failed to build pages',
                    error: flutterError,
                  ),
                ),
              ),
              arguments: <String, Object?>{
                'error': Error.safeToString(error),
                'stack': stackTrace.toString(),
              },
            ),
          ];
        },
      );

  @override
  Future<bool> popRoute() => _handleErrors(() {
        final nav = navigator;
        assert(nav != null, 'Navigator is not attached to the OctopusDelegate');
        if (nav == null) return SynchronousFuture<bool>(false);
        return nav.maybePop();
      });

  Route<Object?>? _onUnknownRoute(
          BuildContext context, RouteSettings settings) =>
      _handleErrors(
        () {
          final widget = _notFound?.call(
              context,
              settings.name ?? 'unknown',
              switch (settings.arguments) {
                Map<String, String> arguments => arguments,
                _ => const <String, String>{},
              });
          if (widget != null)
            return MaterialPageRoute<Object?>(
              builder: (_) => widget,
              settings: settings,
            );
          developer.log(
            'Unknown route ${settings.name}',
            name: 'octopus',
            level: 1000,
            stackTrace: StackTrace.current,
          );
          _onError?.call(
            'Unknown route ${settings.name}',
            StackTrace.current,
          );
          return null;
        },
        (_, __) => null,
      );

  late final OctopusStateQueue _$stateChangeQueue =
      OctopusStateQueue(processor: _setConfiguration);

  @override
  bool get isProcessing => _$stateChangeQueue.isProcessing;

  @override
  Future<void> get processingCompleted =>
      _$stateChangeQueue.processingCompleted;

  void _onIdleState() {
    if (_$stateChangeQueue.isProcessing) return;
    final keys = <String>{};
    currentConfiguration.visitChildNodes((node) {
      keys.add(node.key);
      return true;
    });
    $NodeExtraStorage().removeEverythingExcept(keys);
  }

  @override
  Future<void> setNewRoutePath(covariant OctopusState configuration) async =>
      // Add configuration to the queue to process it later
      _$stateChangeQueue.add(configuration);

  @override
  Future<void> setInitialRoutePath(covariant OctopusState configuration) {
    if (configuration.children.isEmpty) return SynchronousFuture<void>(null);
    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setRestoredRoutePath(covariant OctopusState configuration) {
    if (configuration.children.isEmpty) return SynchronousFuture<void>(null);
    return setNewRoutePath(configuration);
  }

  /// Called when the one of the guards changed.
  void _onGuardsNotified() {
    setNewRoutePath(
        _observer.value.mutate()..intention = OctopusStateIntention.replace);
  }

  /// DO NOT USE THIS METHOD DIRECTLY.
  /// Use [setNewRoutePath] instead.
  /// Used for OctopusStateQueue.
  ///
  /// {@nodoc}
  @protected
  @nonVirtual
  Future<void> _setConfiguration(OctopusState configuration) => _handleErrors(
        () => measureAsync<FutureOr<void>>(
          '_setConfiguration',
          () async {
            // Do nothing:
            if (configuration.intention == OctopusStateIntention.cancel) return;

            // Create a mutable copy of the configuration
            // to allow changing it in the guards
            var newConfiguration = configuration is OctopusState$Mutable
                ? configuration
                : configuration.mutate();

            if (_guards.isNotEmpty) {
              // Get the history of the states
              final history = _observer.history;

              // Unsubscribe from the guards to avoid infinite loop
              _guardsListener.removeListener(_onGuardsNotified);
              final context = <String, Object?>{};
              for (final guard in _guards) {
                try {
                  // Call the guard and get the new state
                  final result =
                      await guard(history, newConfiguration, context);
                  newConfiguration = result.mutate();
                  // Cancel navigation on [OctopusStateIntention.cancel]
                  if (newConfiguration.intention ==
                      OctopusStateIntention.cancel) return;
                } on Object catch (error, stackTrace) {
                  developer.log(
                    'Guard ${guard.runtimeType} failed',
                    name: 'octopus',
                    error: error,
                    stackTrace: stackTrace,
                    level: 1000,
                  );
                  _onError?.call(error, stackTrace);
                  return; // Cancel navigation if the guard failed
                }
              }
              // Resubscribe to the guards
              _guardsListener.addListener(_onGuardsNotified);
            }

            // Validate configuration
            if (newConfiguration.children.isEmpty) return;

            // Normalize configuration
            final result = StateUtil.normalize(newConfiguration);

            if (_observer.changeState(result)) {
              _updateTitle(routes[result.children.lastOrNull?.name]);
              notifyListeners(); // Notify listeners if the state changed
            }
          },
        ),
        (_, __) => SynchronousFuture<void>(null),
      );

  @override
  void dispose() {
    _guardsListener.removeListener(_onGuardsNotified);
    _$stateChangeQueue
      ..removeCompleteListener(_onIdleState)
      ..close();
    super.dispose();
  }

  final Map<String, OctopusDialogPage> _dialogBuilders =
      <String, OctopusDialogPage>{};
  final Map<String, Object?> _dialogResults = <String, Object?>{};

  /// Show a dialog as a declarative page.
  /// {@nodoc}
  @internal
  Future<T?> showDialog<T>(
    WidgetBuilder builder, {
    Map<String, String>? arguments,
  }) async {
    final key = shortHash(UniqueKey());
    final completer = Completer<T?>();
    void onStateChanged() {
      if (completer.isCompleted) return;
      final node = _observer.value.children.firstWhereOrNull((node) =>
          node.name == _kDialogNodeName && node.arguments['k'] == key);
      if (node != null) return;
      final result = _dialogResults.remove(key);
      completer.complete(result is T ? result : null);
    }

    try {
      _dialogBuilders[key] = OctopusDialogPage(
        name: _kDialogNodeName,
        builder: builder,
        arguments: <String, String>{
          'k': key,
          ...?arguments,
        },
        restorationId: null,
      );
      await setNewRoutePath(
        currentConfiguration.mutate()
          ..intention = OctopusStateIntention.navigate
          ..children.add(
            OctopusNode.mutable(
              _kDialogNodeName,
              arguments: <String, String>{
                'k': key,
                ...?arguments,
              },
            ),
          ),
      );
      await Future<void>.delayed(Duration.zero);
      _observer.addListener(onStateChanged);
      onStateChanged();
      final result = await completer.future;
      return result;
    } on Object {
      return null; // ignore errors
    } finally {
      // Clean up
      _observer.removeListener(onStateChanged);
      _dialogBuilders.remove(key);
      _dialogResults.remove(key);
      if (!completer.isCompleted) completer.complete();
    }
  }
}

mixin _TitleMixin {
  String? _$lastTitle;
  Color? _$lastColor;
  // Update title & color
  void _updateTitle(OctopusRoute? route) {
    final title = route?.title;
    final color = route?.color;
    if (title == _$lastTitle && _$lastColor == color) return;
    if (kIsWeb && title == null) return;
    if (!kIsWeb && (title == null || color == null)) return;
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: _$lastTitle = title,
        primaryColor: (_$lastColor = color)?.value,
      ),
    ).ignore();
  }
}
