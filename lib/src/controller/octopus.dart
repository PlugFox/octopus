import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:octopus/src/controller/delegate.dart';
import 'package:octopus/src/controller/guard.dart';
import 'package:octopus/src/controller/information_parser.dart';
import 'package:octopus/src/controller/information_provider.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/state/state_util.dart';
import 'package:octopus/src/widget/navigator.dart';

/// {@template octopus}
/// The main class of the package.
/// Router configuration is provided by the [routes] parameter.
/// {@endtemplate}
abstract base class Octopus {
  /// {@macro octopus}
  factory Octopus({
    required List<OctopusRoute> routes,
    OctopusRoute? defaultRoute,
    List<IOctopusGuard>? guards,
    OctopusState? initialState,
    List<OctopusHistoryEntry>? history,
    Codec<RouteInformation, OctopusState>? codec,
    String? restorationScopeId,
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) = _OctopusImpl;

  Octopus._({required this.config});

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus? maybeOf(BuildContext context) =>
      OctopusNavigator.maybeOf(context);

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus of(BuildContext context) => OctopusNavigator.of(context);

  /// A convenient bundle to configure a [Router] widget.
  final OctopusConfig config;

  /// State observer,
  /// which can be used to listen to changes in the [OctopusState].
  OctopusStateObserver get stateObserver;

  /// Current state.
  OctopusState get state;

  /// History of the [OctopusState] states.
  List<OctopusHistoryEntry> get history;

  /// Set new state and rebuild the navigation tree if needed.
  void setState(OctopusState Function(OctopusState state) change);

  /// Navigate to the specified location.
  void navigate(String location);
}

/// {@nodoc}
final class _OctopusImpl extends Octopus
    with _OctopusDelegateOwner, _OctopusNavigationMixin {
  /// {@nodoc}
  factory _OctopusImpl({
    required List<OctopusRoute> routes,
    OctopusRoute? defaultRoute,
    List<IOctopusGuard>? guards,
    OctopusState? initialState,
    List<OctopusHistoryEntry>? history,
    Codec<RouteInformation, OctopusState>? codec,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    assert(routes.isNotEmpty, 'Routes list should contain at least one route');
    final list = List<OctopusRoute>.of(routes);
    defaultRoute ??= list.firstOrNull;
    if (defaultRoute == null) {
      final error = StateError('Routes list should contain at least one route');
      onError?.call(error, StackTrace.current);
      throw error;
    }
    assert(
      list.map<String>((e) => e.name).toSet().length == list.length,
      'Routes list should not contain duplicate names',
    );
    final routeInformationProvider = OctopusInformationProvider();
    final backButtonDispatcher = RootBackButtonDispatcher();
    final routeInformationParser = OctopusInformationParser(codec: codec);
    final routesTable = Map<String, OctopusRoute>.unmodifiable(
      <String, OctopusRoute>{
        for (final route in routes) route.name: route,
      },
    );
    final routerDelegate = OctopusDelegate(
      initialState: initialState?.freeze() ??
          OctopusState$Immutable(
            children: <OctopusNode>[defaultRoute.node()],
            arguments: const <String, String>{},
          ),
      history: history,
      routes: routesTable,
      defaultRoute: defaultRoute,
      guards: guards,
      restorationScopeId: restorationScopeId,
      observers: observers,
      transitionDelegate: transitionDelegate,
      notFound: notFound,
      onError: onError,
    );
    final controller = _OctopusImpl._(
      routes: routesTable,
      routeInformationProvider: routeInformationProvider,
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher,
    );
    routerDelegate.$controller = WeakReference<Octopus>(controller);
    return controller;
  }

  _OctopusImpl._({
    required Map<String, OctopusRoute> routes,
    required OctopusDelegate routerDelegate,
    required OctopusInformationProvider routeInformationProvider,
    required OctopusInformationParser routeInformationParser,
    required BackButtonDispatcher backButtonDispatcher,
  }) : super._(
          config: OctopusConfig(
            routes: routes,
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            backButtonDispatcher: backButtonDispatcher,
          ),
        );

  @override
  OctopusStateObserver get stateObserver => config.routerDelegate.stateObserver;

  @override
  OctopusState get state => stateObserver.value;

  @override
  List<OctopusHistoryEntry> get history => stateObserver.history;
}

base mixin _OctopusDelegateOwner on Octopus {
  @override
  abstract final OctopusStateObserver stateObserver;
}

base mixin _OctopusNavigationMixin on Octopus {
  @override
  void setState(OctopusState Function(OctopusState state) change) =>
      config.routerDelegate.setNewRoutePath(change(state.mutate()));

  @override
  void navigate(String location) =>
      config.routerDelegate.setNewRoutePath(StateUtil.decodeLocation(location));
}

/// {@template octopus_config}
/// Creates a [OctopusConfig] as a [RouterConfig].
/// {@endtemplate}
class OctopusConfig implements RouterConfig<OctopusState> {
  /// {@macro octopus_config}
  OctopusConfig({
    required this.routes,
    required this.routeInformationProvider,
    required this.routeInformationParser,
    required this.routerDelegate,
    required this.backButtonDispatcher,
  });

  /// The [OctopusRoute]s that are used to configure the [Router].
  final Map<String, OctopusRoute> routes;

  /// The [RouteInformationProvider] that is used to configure the [Router].
  @override
  final OctopusInformationProvider routeInformationProvider;

  /// The [RouteInformationParser] that is used to configure the [Router].
  @override
  final OctopusInformationParser routeInformationParser;

  /// The [RouterDelegate] that is used to configure the [Router].
  @override
  final OctopusDelegate routerDelegate;

  /// The [BackButtonDispatcher] that is used to configure the [Router].
  @override
  final BackButtonDispatcher backButtonDispatcher;
}
