import 'package:example/src/feature/account/widget/account_screen.dart';
import 'package:example/src/feature/account/widget/profile_screen.dart';
import 'package:example/src/feature/account/widget/settings_screen.dart';
import 'package:example/src/feature/authentication/widget/signin_screen.dart';
import 'package:example/src/feature/authentication/widget/signup_screen.dart';
import 'package:example/src/feature/gallery/widget/gallery_screen.dart';
import 'package:example/src/feature/home/widget/home_screen.dart';
import 'package:example/src/feature/shop/widget/basket_screen.dart';
import 'package:example/src/feature/shop/widget/catalog_screen.dart';
import 'package:example/src/feature/shop/widget/category_screen.dart';
import 'package:example/src/feature/shop/widget/favorites_screen.dart';
import 'package:example/src/feature/shop/widget/product_screen.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  signin('signin'),
  signup('signup'),
  home('home'),
  shop('shop'),
  catalog('catalog'),
  category('category'),
  product('product'),
  basket('basket'),
  favorites('favorites'),
  gallery('gallery'),
  account('account'),
  profile('profile'),
  settings('settings');

  const Routes(this.name);

  @override
  final String name;

  @override
  Widget builder(BuildContext context, OctopusNode node) => switch (this) {
        Routes.signin => const SignInScreen(),
        Routes.signup => const SignUpScreen(),
        Routes.home => const HomeScreen(),
        Routes.shop => const ShopScreen(),
        Routes.catalog => const CatalogScreen(),
        Routes.category => CategoryScreen(id: node.arguments['id']),
        Routes.product => ProductScreen(id: node.arguments['id']),
        Routes.basket => const BasketScreen(),
        Routes.favorites => const FavoritesScreen(),
        Routes.gallery => const GalleryScreen(),
        Routes.account => const AccountScreen(),
        Routes.profile => const ProfileScreen(),
        Routes.settings => const SettingsScreen(),
      };
}