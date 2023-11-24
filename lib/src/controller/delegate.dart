import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/octopus.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/widget/octopus_navigator.dart';

/// Octopus delegate.
/// {@nodoc}
@internal
final class OctopusDelegate extends RouterDelegate<OctopusState>
    with ChangeNotifier {
  /// Octopus delegate.
  /// {@nodoc}
  OctopusDelegate({
    required OctopusState initialState,
    required Map<String, OctopusRoute> routes,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  })  : _stateObserver = _OctopusStateObserver(initialState),
        _routes = routes,
        _restorationScopeId = restorationScopeId,
        _observers = observers,
        _transitionDelegate =
            transitionDelegate ?? const DefaultTransitionDelegate<Object?>(),
        _notFound = notFound,
        _onError = onError;

  final _OctopusStateObserver _stateObserver;
  ValueListenable<OctopusState> get stateObserver => _stateObserver;

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
  final Map<String, OctopusRoute> _routes;

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

  /// Current configuration.
  @override
  OctopusState get currentConfiguration => _stateObserver.value;

  @override
  Widget build(BuildContext context) => OctopusNavigator(
        controller: $controller.target!,
        restorationScopeId: _restorationScopeId,
        reportsRouteUpdateToEngine: true,
        observers: <NavigatorObserver>[
          _modalObserver,
          ...?_observers,
        ],
        transitionDelegate: _transitionDelegate,
        pages: buildPagesFromNodes(context, _stateObserver.value.children),
        onPopPage: _onPopPage,
        onUnknownRoute: _onUnknownRoute,
      );

  bool _onPopPage(Route<Object?> route, Object? result) => _handleErrors(
        () {
          if (!route.didPop(result)) return false;
          // TODO(plugfox): make effective pop on immutable state
          {
            final state = _stateObserver.value.mutate();
            final popped = state.maybePop();
            if (popped == null) return false;
            setNewRoutePath(state);
          }
          return true;
        },
        (_, __) => false,
      );

  List<Page<Object?>> buildPagesFromNodes(
          BuildContext context, List<OctopusNode> nodes) =>
      _handleErrors(() {
        final pages = <Page<Object?>>[];
        for (final node in nodes) {
          final route = _routes[node.name];
          assert(route != null, 'Route ${node.name} not found');
          if (route == null) continue;
          final page = route.pageBuilder(context, node);
          pages.add(page);
        }
        if (pages.isNotEmpty) return pages;
        throw FlutterError('The Navigator.pages must not be empty to use the '
            'Navigator.pages API');
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
          /* _onError?.call(
            OctopusUnknownRouteException(settings),
            StackTrace.current,
          ); */
          return null;
        },
        (_, __) => null,
      );

  OctopusState? _$newConfigurationCache;
  @override
  Future<void> setNewRoutePath(covariant OctopusState configuration) {
    if (configuration.children.isEmpty) {
      //assert(false, 'Configuration should not be empty');
      return SynchronousFuture<void>(null);
    }
    _handleErrors(() {
      OctopusState? newConfiguration = configuration;
      // TODO(plugfox): validate and normalize configuration
      _stateObserver.changeState(newConfiguration);
      notifyListeners();
    }, (_, __) {});

    // Use [SynchronousFuture] so that the initial url is processed
    // synchronously and remove unwanted initial animations on deep-linking
    return SynchronousFuture<void>(null);
  }

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
}

final class _OctopusStateObserver
    with ChangeNotifier
    implements ValueListenable<OctopusState$Immutable> {
  _OctopusStateObserver(OctopusState initialState)
      : _value = OctopusState$Immutable.from(initialState);

  @protected
  @nonVirtual
  OctopusState$Immutable _value;

  @override
  OctopusState$Immutable get value => _value;

  @internal
  @nonVirtual
  void changeState(OctopusState? state) {
    if (state == null) return;
    if (state.children.isEmpty) return;
    _value = OctopusState$Immutable.from(state);
    notifyListeners();
  }
}
