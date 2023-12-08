import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/guard.dart';
import 'package:octopus/src/controller/octopus.dart';
import 'package:octopus/src/controller/state_queue.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/widget/navigator.dart';

/// Octopus delegate.
/// {@nodoc}
@internal
final class OctopusDelegate extends RouterDelegate<OctopusState>
    with ChangeNotifier {
  /// Octopus delegate.
  /// {@nodoc}
  OctopusDelegate({
    required OctopusState initialState,
    required OctopusRoute defaultRoute,
    required this.routes,
    List<OctopusHistoryEntry>? history,
    List<IOctopusGuard>? guards,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  })  : _stateObserver = _OctopusStateObserver(initialState, history),
        _defaultRoute = defaultRoute,
        _guards = guards?.toList(growable: false) ?? <IOctopusGuard>[],
        _restorationScopeId = restorationScopeId,
        _observers = observers,
        _transitionDelegate =
            transitionDelegate ?? const DefaultTransitionDelegate<Object?>(),
        _notFound = notFound,
        _onError = onError {
    // Subscribe to the guards.
    _guardsListener = Listenable.merge(_guards)..addListener(_onGuardsNotified);
    // Revalidate the initial state with the guards.
    _setConfiguration(initialState);
  }

  final _OctopusStateObserver _stateObserver;
  OctopusStateObserver get stateObserver => _stateObserver;

  /// The restoration scope id for the navigator.
  final String? _restorationScopeId;

  /// Observers for the navigator.
  final List<NavigatorObserver>? _observers;

  /// Transition delegate.
  final TransitionDelegate<Object?> _transitionDelegate;

  /// Not found route.
  final RouteFactory? _notFound;

  /// Error handler.
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Current octopus instance.
  @internal
  late WeakReference<Octopus> $controller;

  /// Routes hash table.
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
  Widget build(BuildContext context) => OctopusNavigator(
        router: $controller.target!,
        restorationScopeId: _restorationScopeId,
        reportsRouteUpdateToEngine: true,
        observers: <NavigatorObserver>[
          _modalObserver,
          ...?_observers,
        ],
        transitionDelegate: _transitionDelegate,
        pages: buildPagesFromNodes(
          context,
          _stateObserver.value.children,
          _defaultRoute,
        ),
        onPopPage: _onPopPage,
        onUnknownRoute: _onUnknownRoute,
      );

  bool _onPopPage(Route<Object?> route, Object? result) => _handleErrors(
        () {
          if (!route.didPop(result)) return false;
          {
            final state = _stateObserver.value.mutate();
            if (state.children.isEmpty) return false;
            state.children.removeLast();
            setNewRoutePath(state);
          }
          return true;
        },
        (_, __) => false,
      );

  @internal
  List<Page<Object?>> buildPagesFromNodes(
    BuildContext context,
    List<OctopusNode> nodes,
    OctopusRoute defaultRoute,
  ) =>
      _handleErrors(() {
        final pages = <Page<Object?>>[];
        // Build pages
        for (final node in nodes) {
          try {
            final route = routes[node.name];
            assert(route != null, 'Route ${node.name} not found');
            if (route == null) continue;
            final page = route.pageBuilder(context, node);
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
        // Build default page if no pages were built
        return <Page<Object?>>[
          defaultRoute.pageBuilder(
            context,
            defaultRoute.node(),
          ),
        ];
      }, (error, stackTrace) {
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
      });

  @override
  Future<bool> popRoute() => _handleErrors(() {
        final nav = navigator;
        assert(nav != null, 'Navigator is not attached to the OctopusDelegate');
        if (nav == null) return SynchronousFuture<bool>(false);
        return nav.maybePop();
      });

  Route<Object?>? _onUnknownRoute(RouteSettings settings) => _handleErrors(
        () {
          final route = _notFound?.call(settings);
          if (route != null) return route;
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
    setNewRoutePath(_stateObserver.value);
  }

  /// DO NOT USE THIS METHOD DIRECTLY.
  /// Use [setNewRoutePath] instead.
  /// Used for OctopusStateQueue.
  ///
  /// {@nodoc}
  @protected
  @nonVirtual
  Future<void> _setConfiguration(OctopusState configuration) =>
      _handleErrors(() async {
        var newConfiguration = configuration;

        if (_guards.isNotEmpty) {
          // Get the history of the states
          final history = _stateObserver.history;
          // Create a mutable copy of the configuration
          // to allow changing it in the guards
          newConfiguration = newConfiguration.isMutable
              ? newConfiguration
              : newConfiguration.mutate();
          // Unsubscribe from the guards to avoid infinite loop
          _guardsListener.removeListener(_onGuardsNotified);
          final context = <String, Object?>{};
          for (final guard in _guards) {
            try {
              // Call the guard and get the new state
              final result = await guard(history, newConfiguration, context);
              // Cancel navigation if the guard returned null
              if (result == null) return;
              newConfiguration = result;
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
        // Normalize configuration
        // ...

        // Validate configuration
        if (newConfiguration.children.isEmpty) return;

        if (_stateObserver._changeState(newConfiguration)) {
          notifyListeners(); // Notify listeners if the state changed
        }
      }, (_, __) => SynchronousFuture<void>(null));

  @override
  void dispose() {
    _guardsListener.removeListener(_onGuardsNotified);
    super.dispose();
  }
}

/// Octopus state observer.
abstract interface class OctopusStateObserver<T extends OctopusState>
    implements ValueListenable<T> {
  /// Current immutable state.
  @override
  T get value;

  /// History of the states.
  List<OctopusHistoryEntry> get history;
}

final class _OctopusStateObserver
    with ChangeNotifier
    implements OctopusStateObserver<OctopusState$Immutable> {
  _OctopusStateObserver(OctopusState initialState,
      [List<OctopusHistoryEntry>? history])
      : _value = OctopusState$Immutable.from(initialState),
        _history = history?.toSet().toList() ?? <OctopusHistoryEntry>[] {
    // Add the initial state to the history.
    if (_history.isEmpty || _history.last.state != initialState) {
      _history.add(
        OctopusHistoryEntry(
          state: initialState,
          timestamp: DateTime.now(),
        ),
      );
    }
    _history.sort();
  }

  @protected
  @nonVirtual
  OctopusState$Immutable _value;

  @protected
  @nonVirtual
  final List<OctopusHistoryEntry> _history;

  @override
  List<OctopusHistoryEntry> get history =>
      UnmodifiableListView<OctopusHistoryEntry>(_history);

  @override
  OctopusState$Immutable get value => _value;

  @nonVirtual
  bool _changeState(OctopusState state) {
    if (state.children.isEmpty) return false;
    final newValue = OctopusState$Immutable.from(state);
    if (_value == newValue) return false;
    _value = newValue;
    _history.add(
      OctopusHistoryEntry(
        state: newValue,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }
}

/// {@template history_entry}
/// Octopus history entry.
/// {@endtemplate}
@immutable
final class OctopusHistoryEntry implements Comparable<OctopusHistoryEntry> {
  /// {@macro history_entry}
  OctopusHistoryEntry({
    required this.state,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create an entry from json.
  ///
  /// {@macro history_entry}
  factory OctopusHistoryEntry.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'timestamp': String timestamp,
          'state': Map<String, Object?> state,
        }) {
      return OctopusHistoryEntry(
        state: OctopusState.fromJson(state),
        timestamp: DateTime.parse(timestamp),
      );
    } else {
      throw const FormatException('Invalid json');
    }
  }

  /// The state of the entry.
  final OctopusState state;

  /// The timestamp of the entry.
  final DateTime timestamp;

  @override
  int compareTo(covariant OctopusHistoryEntry other) =>
      timestamp.compareTo(other.timestamp);

  /// Convert the entry to json.
  Map<String, Object?> toJson() => <String, Object?>{
        'timestamp': timestamp.toIso8601String(),
        'state': state.toJson(),
      };

  @override
  late final int hashCode = state.hashCode ^ timestamp.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctopusHistoryEntry &&
          timestamp == other.timestamp &&
          state == other.state;
}
