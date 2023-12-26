import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/category_screen.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

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
  Widget build(BuildContext context) {
    final favorites = ShopScope.getFavorites(context, listen: true);
    final products = favorites
        .map<ProductEntity?>(
            (id) => ShopScope.getProductById(context, id, listen: false))
        .whereType<ProductEntity>()
        .toList(growable: false);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // App bar
          SliverAppBar(
            title: const Text('Favorites'),
            pinned: true,
            floating: true,
            snap: true,
            leading: const ShopBackButton(),
            actions: CommonActions(),
            /* expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://picsum.photos/seed/$id/600/200',
                  fit: BoxFit.cover,
                ),
              ), */
          ),

          // Products
          if (products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: false,
              child: Center(
                child: Text('Favorites is empty'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: ProductsSliverGridView(
                  products: products,
                  onTap: (context, product) {
                    context.octopus.setState((state) {
                      final node = state.find((n) => n.name == 'catalog-tab');
                      if (node == null) {
                        return state
                          ..removeByName(Routes.shop.name)
                          ..add(Routes.shop.node(
                            children: <OctopusNode>[
                              OctopusNode.mutable(
                                'catalog-tab',
                                children: [
                                  Routes.catalog.node(),
                                  Routes.product.node(
                                    arguments: {'id': product.id.toString()},
                                  ),
                                ],
                              ),
                            ],
                          ))
                          ..arguments['shop'] = 'catalog';
                      }
                      node.children
                        ..removeWhere((e) =>
                            e.name == Routes.category.name ||
                            e.name == Routes.product.name)
                        ..add(Routes.product.node(
                          arguments: {'id': product.id.toString()},
                        ));
                      return state..arguments['shop'] = 'catalog';
                    });
                  }),
            ),
        ],
      ),
    );
  }
}
