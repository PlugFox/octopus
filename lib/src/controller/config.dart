import 'package:flutter/widgets.dart';
import 'package:octopus/src/controller/delegate.dart';
import 'package:octopus/src/controller/information_parser.dart';
import 'package:octopus/src/controller/information_provider.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/state/state.dart';

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
    required this.observer,
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

  /// The [OctopusStateObserver] that is used to configure the [Router].
  final OctopusStateObserver observer;
}
