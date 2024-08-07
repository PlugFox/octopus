// ignore_for_file: avoid_classes_with_only_static_members

import 'package:meta/meta.dart';
import 'package:octopus/src/util/platform/system_navigator_util_js.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:octopus/src/util/platform/system_navigator_util_vm.dart';

@internal
abstract final class SystemNavigatorUtil {
  static void pushState({Object? data, String? title, Uri? url}) =>
      $pushState(data, title, url);

  static void replaceState({Object? data, String? title, Uri? url}) =>
      $replaceState(data, title, url);

  static void closeApp() => $closeApp();
}
