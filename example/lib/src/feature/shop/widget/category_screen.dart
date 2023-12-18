import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/not_found_screen.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/catalog_breadcrumbs.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template category_screen}
/// CategoryScreen.
/// {@endtemplate}
class CategoryScreen extends StatelessWidget {
  /// {@macro category_screen}
  const CategoryScreen({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) {
    final categoryId = id;
    if (categoryId == null) return const NotFoundScreen();
    final content = ShopScope.getCategoryById(context, categoryId);
    if (content == null) return const NotFoundScreen();
    final CategoryContent(:category, :categories, :products) = content;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // App bar
          SliverAppBar(
            title: Text(category.title),
            pinned: true,
            floating: true,
            snap: true,
            leading: const ShopBackButton(),
            actions: CommonActions(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: SizedBox(
                height: 48,
                child: CatalogBreadcrumbs.category(id: categoryId),
              ),
            ),
            /* expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://picsum.photos/seed/$id/600/200',
                  fit: BoxFit.cover,
                ),
              ), */
          ),

          /// Top padding
          const SliverPadding(
            padding: EdgeInsets.only(top: 16),
          ),

          // Subcategories
          CategoriesSliverListView(categories: categories),

          // Divider
          if (categories.isNotEmpty && products.isNotEmpty)
            SliverPadding(
              padding: ScaffoldPadding.of(context).copyWith(top: 8, bottom: 8),
              sliver: const SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  thickness: 1,
                ),
              ),
            ),

          // Products

          ProductsSliverGridView(products: products),

          /// Bottom padding
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 16),
          ),
        ],
      ),
    );
  }
}

class CategoriesSliverListView extends StatelessWidget {
  const CategoriesSliverListView({
    required this.categories,
    super.key,
  });

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final category = categories[index];
              return ListTile(
                key: ValueKey<CategoryID>(category.id),
                title: Text(category.title),
                onTap: () => Octopus.push(
                  context,
                  Routes.category,
                  arguments: <String, String>{'id': category.id},
                ),
              );
            },
            childCount: categories.length,
          ),
        ),
      );
}

class ProductsSliverGridView extends StatelessWidget {
  const ProductsSliverGridView({
    required this.products,
    this.onTap,
    super.key,
  });

  final List<ProductEntity> products;
  final void Function(BuildContext context, ProductEntity product)? onTap;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 152,
            //mainAxisExtent: 180,
            childAspectRatio: 152 / 180,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductTile(
              product,
              onTap: onTap,
              key: ValueKey<ProductID>(product.id),
            );
          },
        ),
      );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(this.product, {this.onTap, super.key});

  final ProductEntity product;
  final void Function(BuildContext context, ProductEntity product)? onTap;

  Widget discountBanner(Widget child) => product.discountPercentage >= 15
      ? ClipRect(
          child: Banner(
            location: BannerLocation.topEnd,
            message: '${product.discountPercentage.round()}%',
            child: child,
          ),
        )
      : child;

  @override
  Widget build(BuildContext context) => discountBanner(
        Card(
          color: const Color(0xFFcfd8dc),
          margin: EdgeInsets.zero,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onTap == null
                ? Octopus.push(
                    context,
                    Routes.product,
                    arguments: <String, String>{'id': product.id.toString()},
                  )
                : onTap?.call(context, product),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Ink.image(
                              image: product.thumbnail.startsWith('assets/')
                                  ? AssetImage(product.thumbnail)
                                  : NetworkImage(product.thumbnail)
                                      as ImageProvider<Object>,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
