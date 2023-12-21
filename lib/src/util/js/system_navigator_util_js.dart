//import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter

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
  /* html.window.history.pushState(
    data,
    title ?? html.document.title,
    '#$url',
  ); */
}

/// {@nodoc}
@internal
void $replaceState(
  Object? data,
  String? title,
  Uri? url,
) {
  // SystemNavigator.selectMultiEntryHistory(); // selectSingleEntryHistory
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: true,
  );
  /* html.window.history.replaceState(
    data,
    title ?? html.document.title,
    '#$url',
  ); */
}
