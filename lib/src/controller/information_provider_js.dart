import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/information_provider.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/state/state_codec.dart';
import 'package:octopus/src/util/system_navigator_util.dart';

/// {@nodoc}
@internal
final class OctopusInformationProvider$JS extends OctopusInformationProvider {
  /// {@nodoc}
  factory OctopusInformationProvider$JS({
    RouteInformation? initialRouteInformation,
    Listenable? refreshListenable,
  }) {
    final valueInEngine = OctopusInformationProvider.initialRouteInformation();
    return OctopusInformationProvider$JS._(
      valueInEngine: valueInEngine,
      value: initialRouteInformation ?? valueInEngine,
      refreshListenable: refreshListenable,
    );
  }

  /// {@nodoc}
  OctopusInformationProvider$JS._({
    required RouteInformation valueInEngine,
    required RouteInformation value,
    super.refreshListenable,
  })  : _value = value,
        _valueInEngine = valueInEngine,
        _history = <RouteInformation>[value];

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    /* if (neglectIf != null && neglectIf!(routeInformation.uri.toString())) {
      return;
    } */

    /* fine('routerReportsNewRouteInformation(${routeInformation.uri}, '
        '${routeInformation.state})'); */

    if (routeInformation is OctopusRouteInformation) {
      if (routeInformation.intention == OctopusStateIntention.cancel) return;
      if (routeInformation.intention == OctopusStateIntention.neglect) return;
    }

    if (_valueInEngine.uri == routeInformation.uri) {
      return; // Remove dubplicates in history.
    } else if (routeInformation.uri.path.isEmpty) {
      return;
    } else if (!routeInformation.uri.path.startsWith('/')) {
      return;
    }

    // Avoid adding a new history entry if the route is the same as before.
    /* final replace = type == RouteInformationReportingType.neglect ||
        (type == RouteInformationReportingType.none &&
            _valueInEngine.uri == routeInformation.uri &&
            _valueInEngine.state == routeInformation.state); */

    var replace = false;
    switch (routeInformation) {
      case OctopusRouteInformation info
          when info.intention == OctopusStateIntention.cancel ||
              info.intention == OctopusStateIntention.neglect:
        return;
      case OctopusRouteInformation info
          when info.intention == OctopusStateIntention.replace:
        replace = true;
      case OctopusRouteInformation info
          when info.intention == OctopusStateIntention.navigate:
        replace = false;
    }

    switch (type) {
      case RouteInformationReportingType.none:
        if (_valueInEngine.uri == routeInformation.uri) {
          replace = true;
          /* if (identical(_valueInEngine.state, routeInformation.state)) {
            return;
          } else {
            final hashA = jenkinsHash(_valueInEngine.state);
            final hashB = jenkinsHash(routeInformation.state);
            if (hashA == hashB) return;
          } */
        }
      case RouteInformationReportingType.neglect:
        replace = true;
      case RouteInformationReportingType.navigate:
        replace = false;
    }

    // If the route is different from the current route, then update the engine.
    /* if (kIsWeb && routeInformation.uri == _value.uri) {
      config('Uri: ${routeInformation.uri}');
    } */
    /* SystemNavigator.selectMultiEntryHistory(); // selectSingleEntryHistory
    SystemNavigator.routeInformationUpdated(
      uri: routeInformation.uri,
      state: routeInformation.state,
      replace: replace,
    ); */

    if (replace) {
      SystemNavigatorUtil.replaceState(
          data: routeInformation.state, url: routeInformation.uri);
      _history.last = routeInformation;
    } else {
      SystemNavigatorUtil.pushState(
          data: routeInformation.state, url: routeInformation.uri);
      _history.add(routeInformation);
    }
    value = _valueInEngine = routeInformation;
  }

  @override
  RouteInformation get value => _value;
  RouteInformation _value;
  set value(RouteInformation other) {
    final shouldNotify = _value.uri != other.uri;
    _value = other;
    if (shouldNotify) notifyListeners();
  }

  /// History stack of the states.
  /// {@nodoc}
  final List<RouteInformation> _history;

  RouteInformation _valueInEngine;

  bool pushRoute(RouteInformation routeInformation) {
    if (_value == routeInformation) return false;
    _valueInEngine = RouteInformation(uri: Uri());
    if (!routeInformation.uri.path.startsWith('/')) {
      // sims the back button pressed
      if (_history.length < 2) return false;
      _history.removeLast();
      routerReportsNewRouteInformation(
        _history.removeLast(),
        type: RouteInformationReportingType.navigate,
      );
      return true;
    }
    value = routeInformation;
    return true;
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    assert(
        hasListeners,
        'A OctopusInformationProvider must have '
        'at least one listener before it can be used.');
    return SynchronousFuture<bool>(pushRoute(routeInformation));
  }

  @override
  @Deprecated('Use didPushRouteInformation instead')
  Future<bool> didPushRoute(String route) {
    assert(
        hasListeners,
        'A OctopusInformationProvider must have '
        'at least one listener before it can be used.');
    return SynchronousFuture<bool>(
      pushRoute(RouteInformation(uri: Uri.tryParse(route))),
    );
  }

  @override
  Future<bool> didPopRoute() => Future<bool>.value(false);
}
