import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// {@nodoc}
@internal
void $pushState(Object? data, String? title, Uri? url) {
  // SystemNavigator.selectMultiEntryHistory(); // selectSingleEntryHistory
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: false,
  );
}

/// {@nodoc}
@internal
void $replaceState(Object? data, String? title, Uri? url) {
  // SystemNavigator.selectMultiEntryHistory(); // selectSingleEntryHistory
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: true,
  );
}
