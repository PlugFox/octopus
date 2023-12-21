// ignore_for_file: avoid_classes_with_only_static_members

import 'package:meta/meta.dart';
import 'package:octopus/src/util/js/system_navigator_util_js.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:octopus/src/util/js/system_navigator_util_vm.dart';

/// {@nodoc}
@internal
abstract final class SystemNavigatorUtil {
  /// {@nodoc}
  static void pushState({Object? data, String? title, Uri? url}) =>
      $pushState(data, title, url);

  /// {@nodoc}
  static void replaceState({Object? data, String? title, Uri? url}) =>
      $replaceState(data, title, url);
}
