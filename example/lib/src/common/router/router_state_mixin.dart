import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/common/router/authentication_guard.dart';
import 'package:example/src/common/router/home_guard.dart';
import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/router/shop_guard.dart';
import 'package:flutter/widgets.dart' show State, StatefulWidget, ValueNotifier;
import 'package:octopus/octopus.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  late final Octopus router;
  late final ValueNotifier<List<({Object error, StackTrace stackTrace})>>
      errorsObserver;

  @override
  void initState() {
    final dependencies = Dependencies.of(context);
    // Observe all errors.
    errorsObserver =
        ValueNotifier<List<({Object error, StackTrace stackTrace})>>(
      <({Object error, StackTrace stackTrace})>[],
    );

    // Create router.
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
        ShopGuard(),
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
}
