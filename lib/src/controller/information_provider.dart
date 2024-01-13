import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/information_provider_js.dart';
import 'package:octopus/src/controller/information_provider_vm.dart';

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
abstract base class OctopusInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  /// {@nodoc}
  OctopusInformationProvider({
    Listenable? refreshListenable,
  }) : _refreshListenable = refreshListenable {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _refreshListenable?.addListener(notifyListeners);
  }

  factory OctopusInformationProvider.platform({
    RouteInformation? initialRouteInformation,
    Listenable? refreshListenable,
  }) =>
      kIsWeb
          ? OctopusInformationProvider$JS(
              initialRouteInformation: initialRouteInformation,
              refreshListenable: refreshListenable,
            )
          : OctopusInformationProvider$VM(
              initialRouteInformation: initialRouteInformation,
              refreshListenable: refreshListenable,
            );

  static RouteInformation initialRouteInformation() {
    var platformDefault =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName.trim();
    if (platformDefault.isEmpty || !platformDefault.startsWith('/'))
      platformDefault = '/$platformDefault';
    Uri? uri;
    if (platformDefault == '/') {
      uri = Uri();
    } else {
      uri = Uri.tryParse(platformDefault);
    }
    return uri == null ? kEmptyRouteInformation : RouteInformation(uri: uri);
  }

  static final RouteInformation kEmptyRouteInformation =
      RouteInformation(uri: Uri());

  final Listenable? _refreshListenable;

  static WidgetsBinding get _binding => WidgetsBinding.instance;

  @override
  @mustCallSuper
  void addListener(VoidCallback listener) {
    if (!hasListeners) _binding.addObserver(this);
    super.addListener(listener);
  }

  @override
  @mustCallSuper
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _binding.removeObserver(this);
  }

  @override
  @mustCallSuper
  void dispose() {
    if (hasListeners) _binding.removeObserver(this);
    _refreshListenable?.removeListener(notifyListeners);
    super.dispose();
  }
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
