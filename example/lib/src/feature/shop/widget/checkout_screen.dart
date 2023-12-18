import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

/// {@template checkout_screen}
/// CheckoutScreen widget.
/// {@endtemplate}
class CheckoutScreen extends StatelessWidget {
  /// {@macro checkout_screen}
  const CheckoutScreen({super.key});

  void pay(BuildContext context) {
    Octopus.of(context).setState((state) => state
      ..removeByName(Routes.checkout.name)
      ..arguments['shop'] = ShopTabsEnum.catalog.name);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Payment successful'),
        backgroundColor: Colors.green,
      ),
    );
    HapticFeedback.mediumImpact().ignore();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
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
                  child: const FormPlaceholder(),
                ),
              ),
              Padding(
                padding: ScaffoldPadding.of(context).copyWith(
                  bottom: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => pay(context),
                          label: const Text('Card'),
                          icon: const Icon(Icons.credit_card),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => pay(context),
                          label: const Text('PayPal'),
                          icon: const Icon(Icons.payment),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
