import 'package:example/src/common/constant/config.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/common/router/authentication_guard.dart';
import 'package:example/src/common/router/home_guard.dart';
import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/router_state_observer.dart';
import 'package:example/src/feature/authentication/widget/authentication_scope.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
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
  late final ValueNotifier<List<({Object error, StackTrace stackTrace})>>
      errorsObserver;

  @override
  void initState() {
    final dependencies = Dependencies.of(context);
    errorsObserver =
        ValueNotifier<List<({Object error, StackTrace stackTrace})>>(
      <({Object error, StackTrace stackTrace})>[],
    );
    router = Octopus(
      routes: Routes.values,
      defaultRoute: Routes.home,
      guards: <IOctopusGuard>[
        AuthenticationGuard(
          getUser: () => dependencies.authenticationController.state.user,
          routes: <String>{
            Routes.signin.name,
            Routes.signup.name,
          },
          signinNavigation: OctopusState.single(Routes.signin.node()),
          homeNavigation: OctopusState.single(Routes.home.node()),
          refresh: dependencies.authenticationController,
        ),
        HomeGuard(),
      ],
      onError: (error, stackTrace) =>
          errorsObserver.value = <({Object error, StackTrace stackTrace})>[
        (error: error, stackTrace: stackTrace),
        ...errorsObserver.value,
      ],
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
    super.initState();
  }

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
