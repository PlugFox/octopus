// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

//import 'package:flutter_web_plugins/url_strategy.dart';
//import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Future<void> $platformInitialization() async {
  //setUrlStrategy(const HashUrlStrategy());

  // Remove splash screen
  Future<void>.delayed(
    const Duration(seconds: 1),
    () {
      // Before running your app:
      //setUrlStrategy(null); // const HashUrlStrategy();
      //setUrlStrategy(NoHistoryUrlStrategy());

      html.document.getElementById('splash')?.remove();
      html.document.getElementById('splash-branding')?.remove();
      html.document.body?.style.background = 'transparent';
      html.document
          .getElementsByClassName('splash-loading')
          .toList(growable: false)
          .forEach((element) => element.remove());
    },
  );
}

/* class NoHistoryUrlStrategy extends PathUrlStrategy {
  @override
  void pushState(Object? state, String title, String url) =>
      replaceState(state, title, url);
}
*/
