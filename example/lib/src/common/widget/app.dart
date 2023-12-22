import 'package:example/src/common/constant/config.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/router/router_state_mixin.dart';
import 'package:example/src/common/widget/router_state_observer.dart';
import 'package:example/src/feature/authentication/widget/authentication_scope.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RouterStateMixin {
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Octopus: example',
        debugShowCheckedModeBanner: !Config.environment.isProduction,

        // Router
        routerConfig: router.config,

        // Localizations
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          Localization.delegate,
        ],
        supportedLocales: Localization.supportedLocales,
        /* locale: SettingsScope.localOf(context), */

        // Theme
        /* theme: SettingsScope.themeOf(context), */
        theme: ThemeData.light(),

        // Scopes
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: ShopScope(
            child: AuthenticationScope(
              child: RouterStateObserver(
                octopus: router,
                errorsObserver: errorsObserver,
                child: child!,
              ),
            ),
          ),
        ),
      );
}
