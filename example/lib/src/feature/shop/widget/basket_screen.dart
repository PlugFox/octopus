import 'package:example/src/common/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template basket_tab}
/// BasketTab widget.
/// {@endtemplate}
class BasketTab extends StatelessWidget {
  /// {@macro basket_tab}
  const BasketTab({super.key});

  @override
  Widget build(BuildContext context) => const BasketScreen();
}

/// {@template basket_screen}
/// BasketScreen widget.
/// {@endtemplate}
class BasketScreen extends StatelessWidget {
  /// {@macro basket_screen}
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Basket'),
          leading: BackButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.maybePop(context);
                return;
              }
              // On back button pressed, close shop tabs
              Octopus.of(context).setState(
                (state) => state
                  ..removeWhere(
                    (route) => route.name == Routes.shop.name,
                  ),
              );
            },
          ),
        ),
        body: const SafeArea(
          child: Placeholder(),
        ),
      );
}
