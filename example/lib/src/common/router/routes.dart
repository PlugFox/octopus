import 'package:example/src/feature/account/widget/about_app_dialog.dart';
import 'package:example/src/feature/account/widget/profile_screen.dart';
import 'package:example/src/feature/account/widget/settings_dialog.dart';
import 'package:example/src/feature/authentication/widget/signin_screen.dart';
import 'package:example/src/feature/authentication/widget/signup_screen.dart';
import 'package:example/src/feature/gallery/widget/gallery_screen.dart';
import 'package:example/src/feature/gallery/widget/picture_screen.dart';
import 'package:example/src/feature/home/widget/home_screen.dart';
import 'package:example/src/feature/shop/shop_screens.dart'
    deferred as shop_screens;
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
  productImageDialog('product-img-dialog', title: 'Product\'s Image'),
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
        Routes.shop =>
          _ShopLoader(builder: (context) => shop_screens.ShopScreen()),
        Routes.catalog => _ShopLoader(
            builder: (context) => shop_screens.CatalogScreen(),
          ),
        Routes.category => _ShopLoader(
            builder: (context) =>
                shop_screens.CategoryScreen(id: node.arguments['id']),
          ),
        Routes.product => _ShopLoader(
            builder: (context) =>
                shop_screens.ProductScreen(id: node.arguments['id']),
          ),
        Routes.productImageDialog => _ShopLoader(
            builder: (context) => shop_screens.ProductImageDialog(
              id: node.arguments['id'],
              idx: node.arguments['idx'],
            ),
          ),
        Routes.basket => _ShopLoader(
            builder: (context) => shop_screens.BasketScreen(),
          ),
        Routes.checkout => _ShopLoader(
            builder: (context) => shop_screens.CheckoutScreen(),
          ),
        Routes.favorites => _ShopLoader(
            builder: (context) => shop_screens.FavoritesScreen(),
          ),
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

class _ShopLoader extends StatelessWidget {
  const _ShopLoader({
    required this.builder,
    super.key, // ignore: unused_element
  });

  static final Future<void> _loadShop = shop_screens.loadLibrary();

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        initialData: null,
        future: _loadShop,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return builder(context);
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
}
