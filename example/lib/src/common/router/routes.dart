import 'package:example/src/feature/account/widget/about_app_dialog.dart';
import 'package:example/src/feature/account/widget/profile_screen.dart';
import 'package:example/src/feature/account/widget/settings_dialog.dart';
import 'package:example/src/feature/authentication/widget/signin_screen.dart';
import 'package:example/src/feature/authentication/widget/signup_screen.dart';
import 'package:example/src/feature/gallery/widget/gallery_screen.dart';
import 'package:example/src/feature/gallery/widget/picture_screen.dart';
import 'package:example/src/feature/home/widget/home_screen.dart';
import 'package:example/src/feature/shop/widget/basket_screen.dart';
import 'package:example/src/feature/shop/widget/catalog_screen.dart';
import 'package:example/src/feature/shop/widget/category_screen.dart';
import 'package:example/src/feature/shop/widget/checkout_screen.dart';
import 'package:example/src/feature/shop/widget/favorites_screen.dart';
import 'package:example/src/feature/shop/widget/product_screen.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  signup('signup', title: 'Sign-Up'),
  home('home', title: 'Octopus'),
  shop('shop', title: 'Shop'),
  catalog('catalog', title: 'Catalog'),
  category('category', title: 'Category'),
  product('product', title: 'Product'),
  basket('basket', title: 'Basket'),
  checkout('checkout', title: 'Checkout'),
  favorites('favorites', title: 'Favorites'),
  gallery('gallery', title: 'Gallery'),
  picture('picture', title: 'Picture'),
  profile('profile', title: 'Profile'),
  settingsDialog('settings-dialog', title: 'Settings'),
  aboutAppDialog('about-app-dialog', title: 'About Application');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) =>
      switch (this) {
        Routes.signin => const SignInScreen(),
        Routes.signup => const SignUpScreen(),
        Routes.home => const HomeScreen(),
        Routes.shop => const ShopScreen(),
        Routes.catalog => const CatalogScreen(),
        Routes.category => CategoryScreen(id: node.arguments['id']),
        Routes.product => ProductScreen(id: node.arguments['id']),
        Routes.basket => const BasketScreen(),
        Routes.checkout => const CheckoutScreen(),
        Routes.favorites => const FavoritesScreen(),
        Routes.gallery => const GalleryScreen(),
        Routes.picture => PictureScreen(id: node.arguments['id']),
        Routes.profile => const ProfileScreen(),
        Routes.settingsDialog => const SettingsDialog(),
        Routes.aboutAppDialog => const AboutApplicationDialog(),
      };

  /*
  @override
  Page<Object?> pageBuilder(BuildContext context, OctopusNode node) =>
      node.name.endsWith('-custom')
          ? CustomUserPage()
          : super.pageBuilder(context, node);
  */
}
