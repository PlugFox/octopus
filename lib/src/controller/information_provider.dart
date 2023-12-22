import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/state/state_codec.dart';
import 'package:octopus/src/util/jenkins_hash.dart';
import 'package:octopus/src/util/logs.dart';
import 'package:octopus/src/util/system_navigator_util.dart';

/// The route information provider that propagates
/// the platform route information changes.
///
/// This provider also reports the new route
/// information from the [Router] widget
/// back to engine using message channel method, the
/// [SystemNavigator.routeInformationUpdated].
///
/// Each time [SystemNavigator.routeInformationUpdated] is called, the
/// [SystemNavigator.selectMultiEntryHistory] method is also called. This
/// overrides the initialization behavior of
/// [Navigator.reportsRouteUpdateToEngine].
///
/// See more [PlatformRouteInformationProvider]
///
/// {@nodoc}
@internal
class OctopusInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  factory OctopusInformationProvider({
    RouteInformation? initialRouteInformation,
    Listenable? refreshListenable,
  }) {
    final valueInEngine = _initialRouteInformation();
    return OctopusInformationProvider._(
      valueInEngine: valueInEngine,
      value: initialRouteInformation ?? valueInEngine,
      refreshListenable: refreshListenable,
    );
  }

  /// {@nodoc}
  OctopusInformationProvider._({
    required RouteInformation valueInEngine,
    required RouteInformation value,
    Listenable? refreshListenable,
  })  : _value = value,
        _valueInEngine = valueInEngine,
        _refreshListenable = refreshListenable {
    /* if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    } */
    _refreshListenable?.addListener(notifyListeners);
  }

  static RouteInformation _initialRouteInformation() {
    final platformDefault =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    Uri? uri;
    if (platformDefault == '/' || platformDefault == '') {
      uri = Uri();
    } else {
      uri = Uri.tryParse(platformDefault);
    }
    return uri == null ? _kEmptyRouteInformation : RouteInformation(uri: uri);
  }

  final Listenable? _refreshListenable;

  static WidgetsBinding get _binding => WidgetsBinding.instance;
  static final RouteInformation _kEmptyRouteInformation =
      RouteInformation(uri: Uri());

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    /* if (neglectIf != null && neglectIf!(routeInformation.uri.toString())) {
      return;
    } */

    if (routeInformation is OctopusRouteInformation) {
      if (routeInformation.intention == OctopusStateIntention.cancel) return;
      if (routeInformation.intention == OctopusStateIntention.neglect) return;
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
      default:
        switch (type) {
          case RouteInformationReportingType.none:
            if (_valueInEngine.uri == routeInformation.uri) {
              if (identical(_valueInEngine.state, routeInformation.state)) {
                replace = true;
              } else {
                final hashA = jenkinsHash(_valueInEngine.state);
                final hashB = jenkinsHash(routeInformation.state);
                if (hashA == hashB) replace = true;
              }
            }
            if (replace) return; // Avoid adding a new history entry.
          case RouteInformationReportingType.neglect:
            replace = true;
          case RouteInformationReportingType.navigate:
            replace = false;
        }
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
        data: routeInformation.state,
        url: routeInformation.uri,
        /* title: , */
      );
    } else {
      SystemNavigatorUtil.pushState(
        data: routeInformation.state,
        url: routeInformation.uri,
        /* title: , */
      );
    }
    _value = _valueInEngine = routeInformation;
  }

  @override
  RouteInformation get value => _value;
  RouteInformation _value;
  set value(RouteInformation other) {
    final shouldNotify = _value.uri != other.uri || _value.state != other.state;
    _value = other;
    if (shouldNotify) notifyListeners();
  }

  RouteInformation _valueInEngine;

  void pushRoute(RouteInformation routeInformation) {
    if (_value == routeInformation) return;
    fine('pushRoute(${routeInformation.uri}, ${routeInformation.state})');
    // If the route information is an OctopusRouteInformation,
    // then handle it and set it as the current route information.
    if (routeInformation is OctopusRouteInformation) {
      _value = _valueInEngine = routeInformation;
      notifyListeners();
      return;
    }
    // If the route information has a state containing information about
    // the children, then handle it, decode the state and set it as the
    // current route information.
    if (routeInformation.state case Map<String, Object?> json) {
      if (json.containsKey('children')) {
        final state = OctopusState.fromJson(json);
        _value = _valueInEngine = OctopusRouteInformation(state);
        notifyListeners();
        return;
      }
    }
    final uri = routeInformation.uri;
    // If location does not start with a '/',
    // then handle it as a pop operation.
    if (!routeInformation.uri.path.startsWith('/'))
      return popUri(routeInformation);
    _value = RouteInformation(
      uri: uri,
      state: null,
    );
    _valueInEngine = _kEmptyRouteInformation;
    notifyListeners();
  }

  void popUri(RouteInformation routeInformation) {
    final popUri = routeInformation.uri;
    fine('popFromUri($popUri)');
    var popTo = popUri.path;
    popTo = popTo.startsWith('/') ? popTo : '/$popTo';
    var path = _value.uri.path;
    if (path.endsWith(popTo)) {
      path = path.substring(0, path.length - popTo.length);
    } else {
      final idx = path.lastIndexOf('$popTo/');
      if (idx == -1) {
        warning('Cannot pop to "$popTo" from "$path"');
      } else {
        path = path.substring(0, idx);
      }
    }
    while (path.startsWith('//')) path = path.substring(1);
    while (path.endsWith('/')) path = path.substring(0, path.length - 1);

    //if (path.isEmpty || path == '/')
    _value = RouteInformation(
      uri: _value.uri.replace(path: path),
      state: null,
    );
    _valueInEngine = _kEmptyRouteInformation;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) _binding.addObserver(this);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _binding.removeObserver(this);
  }

  @override
  void dispose() {
    if (hasListeners) _binding.removeObserver(this);
    _refreshListenable?.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    assert(
        hasListeners,
        'A OctopusInformationProvider must have '
        'at least one listener before it can be used.');
    pushRoute(routeInformation);
    return SynchronousFuture<bool>(true);
  }

  @override
  @Deprecated('Use didPushRouteInformation instead')
  Future<bool> didPushRoute(String route) {
    assert(
        hasListeners,
        'A OctopusInformationProvider must have '
        'at least one listener before it can be used.');
    pushRoute(RouteInformation(uri: Uri.tryParse(route)));
    return SynchronousFuture<bool>(true);
  }

  @override
  Future<bool> didPopRoute() => Future<bool>.value(false);
}

/* Useful methods for the package

  SystemNavigator.pop();
  SystemNavigator.setFrameworkHandlesBack(true);
  SystemNavigator.selectMultiEntryHistory();
  SystemNavigator.selectSingleEntryHistory();
  SystemNavigator.routeInformationUpdated(
    uri: Uri.parse('/'),
    state: const <String, Object?>{},
    replace: false,
  );
  Router.neglect(context, () {});
  Router.navigate(context, () {});
*/
