import 'package:example/src/feature/category/widget/category_screen.dart';
import 'package:example/src/feature/product/widget/product_screen.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  shop('shop'),
  category('category'),
  product('product');

  const Routes(this.name);

  @override
  final String name;

  @override
  Widget builder(BuildContext context, OctopusNode node) => switch (this) {
        Routes.shop => const ShopScreen(),
        Routes.category => CategoryScreen(id: node.arguments['id']),
        Routes.product => ProductScreen(id: node.arguments['id']),
      };
}
