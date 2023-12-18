import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:flutter/material.dart';

/// {@template favorites_tab}
/// FavoritesTab widget.
/// {@endtemplate}
class FavoritesTab extends StatelessWidget {
  /// {@macro favorites_tab}
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) => const FavoritesScreen();
}

/// {@template favorites_screen}
/// FavoritesScreen widget.
/// {@endtemplate}
class FavoritesScreen extends StatelessWidget {
  /// {@macro favorites_screen}
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          actions: CommonActions(),
          leading: const ShopBackButton(),
        ),
        body: const SafeArea(
          child: Placeholder(),
        ),
      );
}
