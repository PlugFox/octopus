import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/util/logs.dart';

/// Push state.
@internal
void $pushState(Object? data, String? title, Uri? url) {
  fine('pushState($url)');
  // SystemNavigator.selectMultiEntryHistory(); // selectSingleEntryHistory
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: false,
  ).ignore();
}

/// Replace state.
@internal
void $replaceState(Object? data, String? title, Uri? url) {
  fine('replaceState($url)');
  // SystemNavigator.selectMultiEntryHistory(); // selectSingleEntryHistory
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: true,
  ).ignore();
}

/// Close app.
@internal
void $closeApp() {
  fine('closeApp()');
  SystemNavigator.pop().ignore();
}
