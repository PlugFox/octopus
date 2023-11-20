import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/router_state_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:octopus/octopus.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final Octopus router;

  @override
  void initState() {
    router = Octopus(
      routes: Routes.values,
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Example',
        debugShowCheckedModeBanner: false,
        routerConfig: router.config,
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          /* Localization.delegate, */
        ],
        /* theme: SettingsScope.themeOf(context), */
        /* supportedLocales: Localization.supportedLocales,
        locale: switch (SettingsScope.of(context).locale) {
          String locale when locale.isNotEmpty => Locale(locale),
          _ => null,
        }, */
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: RouterStateObserver(
            listenable: router.stateObserver,
            child: child!,
          ),
        ),
      );
}
