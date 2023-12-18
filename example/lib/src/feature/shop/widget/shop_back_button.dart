import 'package:example/src/common/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template shop_back_button}
/// ShopBackButton widget.
/// {@endtemplate}
class ShopBackButton extends StatelessWidget {
  /// {@macro shop_back_button}
  const ShopBackButton({super.key});

  @override
  Widget build(BuildContext context) => BackButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.maybePop(context);
            return;
          }
          // Fallback: on back button pressed, close shop tabs
          final router = Octopus.maybeOf(context);
          if (router == null) return;
          final shop =
              router.state.find((route) => route.name == Routes.shop.name);
          if (shop == null) {
            router.setState((state) => state..removeLast());
          } else {
            router.setState((state) => state
              ..removeWhere(
                (route) => route.name == Routes.shop.name,
              ));
          }
        },
      );
}
