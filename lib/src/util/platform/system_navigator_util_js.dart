// ignore_for_file: avoid_web_libraries_in_flutter, unsafe_html

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/util/logs.dart';

/// Push state.
@internal
void $pushState(Object? data, String? title, Uri? url) {
  fine('pushState($url)');
  SystemNavigator.selectMultiEntryHistory().ignore();
  //SystemNavigator.selectSingleEntryHistory().ignore();
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: false,
  ).ignore();
  /* html.window.history.pushState(
    data,
    title ?? html.document.title,
    '#$url',
  ); */
}

/// Replace state.
@internal
void $replaceState(
  Object? data,
  String? title,
  Uri? url,
) {
  fine('replaceState($url)');
  SystemNavigator.selectMultiEntryHistory().ignore();
  //SystemNavigator.selectSingleEntryHistory().ignore();
  SystemNavigator.routeInformationUpdated(
    uri: url,
    state: data,
    replace: true,
  ).ignore();
  /* html.window.history.replaceState(
    data,
    title ?? html.document.title,
    '#$url',
  ); */
}

/// Close app.
@internal
void $closeApp() {
  fine('closeApp()');
  SystemNavigator.pop().ignore();
  /* try {
    html.window.open('', '_self').close();
  } on Object {/* */} */
}
