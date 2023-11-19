import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:octopus/src/controller/delegate.dart';
import 'package:octopus/src/controller/information_parser.dart';
import 'package:octopus/src/controller/information_provider.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/utils/state_util.dart';

/// {@template octopus}
/// The main class of the package.
/// Router configuration is provided by the [routes] parameter.
/// {@endtemplate}
abstract base class Octopus {
  /// {@macro octopus}
  factory Octopus({
    required List<OctopusRoute> routes,
    OctopusRoute? home,
    String? restorationScopeId,
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) = _OctopusImpl;

  Octopus._({required this.config});

  /// A convenient bundle to configure a [Router] widget.
  final RouterConfig<OctopusState> config;

  /// Current state.
  OctopusState get state;

  /// State observer,
  /// which can be used to listen to changes in the [OctopusState].
  ValueListenable<OctopusState> get stateObserver;

  /// Set new state and rebuild the navigation tree if needed.
  void setState(OctopusState Function(OctopusState state) change);

  /// Navigate to the specified location.
  void navigate(String location);

  // TODO(plugfox): history
}

/// {@nodoc}
final class _OctopusImpl extends Octopus
    with _OctopusDelegateOwner, _OctopusNavigationMixin {
  /// {@nodoc}
  factory _OctopusImpl({
    required List<OctopusRoute> routes,
    OctopusRoute? home,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    assert(routes.isNotEmpty, 'Routes list should contain at least one route');
    final list = List<OctopusRoute>.of(routes);
    final defaultRoute = home ?? list.firstOrNull;
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
    final routeInformationParser = OctopusInformationParser();
    final routerDelegate = OctopusDelegate(
      initialState: OctopusState(
        children: <OctopusNode>[defaultRoute.node()],
        arguments: <String, String>{},
      ),
      routes: list,
      restorationScopeId: restorationScopeId,
      observers: observers,
      transitionDelegate: transitionDelegate,
      notFound: notFound,
      onError: onError,
    );
    final controller = _OctopusImpl._(
      routeInformationProvider: routeInformationProvider,
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher,
    );
    return controller;
  }

  _OctopusImpl._({
    required OctopusDelegate routerDelegate,
    required RouteInformationProvider routeInformationProvider,
    required RouteInformationParser<OctopusState> routeInformationParser,
    required BackButtonDispatcher backButtonDispatcher,
  })  : stateObserver = routerDelegate,
        super._(
          config: RouterConfig<OctopusState>(
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            backButtonDispatcher: backButtonDispatcher,
          ),
        );

  @override
  OctopusState get state => stateObserver.currentConfiguration;

  @override
  final OctopusDelegate stateObserver;
}

base mixin _OctopusDelegateOwner on Octopus {
  @override
  abstract final OctopusDelegate stateObserver;
}

base mixin _OctopusNavigationMixin on _OctopusDelegateOwner, Octopus {
  @override
  void setState(OctopusState Function(OctopusState state) change) =>
      stateObserver.setNewRoutePath(change(state));

  @override
  void navigate(String location) =>
      stateObserver.setNewRoutePath(StateUtil.decodeLocation(location));
}
