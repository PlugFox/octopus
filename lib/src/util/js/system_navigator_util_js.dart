// ignore_for_file: avoid_web_libraries_in_flutter, unsafe_html
//import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/util/logs.dart';

/// {@nodoc}
@internal
void $pushState(Object? data, String? title, Uri? url) {
  fine('pushState($url)');
  //SystemNavigator.selectSingleEntryHistory();
  /* SystemNavigator.selectMultiEntryHistory().whenComplete(() {
    SystemNavigator.routeInformationUpdated(
      uri: url,
      state: data,
      replace: false,
    );
  }); */
  SystemNavigator.selectMultiEntryHistory().ignore();
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

/// {@nodoc}
@internal
void $replaceState(
  Object? data,
  String? title,
  Uri? url,
) {
  fine('replaceState($url)');
  //SystemNavigator.selectSingleEntryHistory();
  /* SystemNavigator.selectMultiEntryHistory().whenComplete(() {
    SystemNavigator.routeInformationUpdated(
      uri: url,
      state: data,
      replace: true,
    );
  }); */
  SystemNavigator.selectMultiEntryHistory().ignore();
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

/// {@nodoc}
@internal
void $closeApp() {
  fine('closeApp()');
  SystemNavigator.pop().ignore();
  /* try {
    html.window.open('', '_self').close();
  } on Object {/* */} */
}
