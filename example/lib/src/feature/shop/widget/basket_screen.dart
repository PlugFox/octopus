import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template basket_tab}
/// BasketTab widget.
/// {@endtemplate}
class BasketTab extends StatelessWidget {
  /// {@macro basket_tab}
  const BasketTab({super.key});

  @override
  Widget build(BuildContext context) => OctopusNavigator.nested(
        bucket: '${ShopTabsEnum.basket.value}-tab',
        defaultRoute: Routes.basket,
      );
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
          leading: const ShopBackButton(),
          actions: CommonActions(),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: ScaffoldPadding.of(context).copyWith(
                    top: 16,
                    bottom: 16,
                  ),
                  child: const FormPlaceholder(
                    title: true,
                  ),
                ),
              ),
              Padding(
                padding: ScaffoldPadding.of(context).copyWith(
                  bottom: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () => Octopus.push(
                      context,
                      Routes.checkout,
                    ),
                    label: const Text('Checkout'),
                    icon: const Icon(Icons.check),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
