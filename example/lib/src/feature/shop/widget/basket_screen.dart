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

  static const double _bottomHeight = 48 + 16 + 16;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Basket'),
          leading: const ShopBackButton(),
          actions: CommonActions(),
        ),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              // Scrollable body
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: ScaffoldPadding.of(context).copyWith(
                    top: 16,
                    bottom: _bottomHeight + 16,
                  ),
                  child: const FormPlaceholder(
                    title: true,
                  ),
                ),
              ),

              // Bottom gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _bottomHeight + 48,
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const <Color>[
                          Colors.transparent,
                          Colors.purple,
                          Colors.purple,
                        ],
                        stops: <double>[
                          0,
                          1.0 - _bottomHeight / bounds.height,
                          1,
                        ],
                      ).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      child: const ColoredBox(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Checkout button
              Positioned(
                height: _bottomHeight,
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: ScaffoldPadding.of(context),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => Octopus.push(
                          context,
                          Routes.checkout,
                        ),
                        label: const Text(
                          'Checkout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1,
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        icon: const Icon(
                          Icons.check,
                          size: 24,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
