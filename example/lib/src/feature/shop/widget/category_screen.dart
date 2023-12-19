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
import 'package:google_fonts/google_fonts.dart';
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
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
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

  Widget discountBanner({required Widget child}) =>
      product.discountPercentage >= 15
          ? ClipRect(
              child: Banner(
                location: BannerLocation.topEnd,
                message: '${product.discountPercentage.round()}%',
                child: child,
              ),
            )
          : child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.all(4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: <Widget>[
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: discountBanner(
                                  child: _ProductCardImage(product: product)),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(-.65, .75),
                            child: _ProductPriceTag(product: product),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Align(
                      alignment: const Alignment(0, -.5),
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 0.9,
                          letterSpacing: -0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tap area
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                hoverColor: theme.hoverColor,
                splashColor: theme.splashColor,
                highlightColor: theme.highlightColor,
                onTap: () => onTap == null
                    ? Octopus.push(
                        context,
                        Routes.product,
                        arguments: <String, String>{
                          'id': product.id.toString()
                        },
                      )
                    : onTap?.call(context, product),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  const _ProductCardImage({
    required this.product,
    super.key, // ignore: unused_element
  });

  final ProductEntity product;

  ImageProvider<Object> get _imageProvider =>
      (product.thumbnail.startsWith('assets/')
          ? AssetImage(product.thumbnail)
          : NetworkImage(product.thumbnail)) as ImageProvider<Object>;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: _imageProvider,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      );
}

class _ProductPriceTag extends StatelessWidget {
  const _ProductPriceTag({
    required this.product,
    super.key, // ignore: unused_element
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: GoogleFonts.coiny(
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
              shadows: <Shadow>[
                const BoxShadow(
                  color: Colors.black,
                  offset: Offset.zero,
                  blurRadius: 1,
                  blurStyle: BlurStyle.solid,
                ),
                const BoxShadow(
                  color: Colors.black,
                  offset: Offset.zero,
                  blurRadius: 2,
                  blurStyle: BlurStyle.solid,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    r'$',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                Text(
                  product.price.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
