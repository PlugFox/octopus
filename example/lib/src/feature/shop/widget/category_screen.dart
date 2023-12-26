import 'package:example/src/common/constant/config.dart';
import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/not_found_screen.dart';
import 'package:example/src/common/widget/outlined_text.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/catalog_breadcrumbs.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/foundation.dart';
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
                onTap: () => context.octopus.setState((state) => state
                  ..findByName('catalog-tab')?.add(Routes.category.node(
                    arguments: <String, String>{'id': category.id},
                  ))),
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
                color: Colors.red,
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
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
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
                              padding: const EdgeInsets.all(2),
                              child: discountBanner(
                                  child: _ProductCardImage(product: product)),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(-.95, .95),
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
                    ? context.octopus.setState((state) => state
                      ..findByName('catalog-tab')?.add(Routes.product.node(
                          arguments: <String, String>{
                            'id': product.id.toString()
                          })))
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
      (!kIsWeb || Config.environment.isDevelopment
          ? AssetImage(product.thumbnail)
          : NetworkImage('/${product.thumbnail}')) as ImageProvider<Object>;

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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: CustomPaint(
          painter: const _SlantedRectanglePainter(
            padding: EdgeInsets.only(bottom: 10, right: 10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: DefaultTextStyle(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: const TextStyle(
                height: 1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: OutlinedText(
                      r'$',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 0,
                      ),
                      strokeWidth: 2,
                      fillColor: Colors.blue,
                      strokeColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 1),
                  OutlinedText(
                    product.price.toStringAsFixed(0),
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 0,
                    ),
                    strokeWidth: 4,
                    fillColor: Colors.blue,
                    strokeColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SlantedRectanglePainter extends CustomPainter {
  const _SlantedRectanglePainter({
    this.padding = EdgeInsets.zero, // ignore: unused_element
    super.repaint, // ignore: unused_element
  });

  final EdgeInsets padding;
  static final Paint _paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      // Начальная точка с левого верхнего угла
      ..moveTo(size.width * 0.1 + padding.left, padding.top)
      // Верхняя горизонтальная линия
      ..lineTo(size.width - padding.right, padding.top)
      // Наклонная правая линия
      ..lineTo(size.width * 0.9 - padding.right, size.height - padding.bottom)
      // Нижняя горизонтальная линия
      ..lineTo(padding.left, size.height - padding.bottom)
      // Замыкаем путь
      ..close();

    canvas
      // Рисуем тень
      ..drawShadow(path, Colors.black, 8, false)
      // Рисуем фигуру
      ..drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant _SlantedRectanglePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(covariant _SlantedRectanglePainter oldDelegate) =>
      false;
}
