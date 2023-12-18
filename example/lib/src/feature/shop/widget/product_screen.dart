import 'dart:async';

import 'package:collection/collection.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/not_found_screen.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/favorite/widget/favorite_button.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/catalog_breadcrumbs.dart';
import 'package:example/src/feature/shop/widget/product_image_screen.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template product_screen}
/// ProductScreen widget.
/// {@endtemplate}
class ProductScreen extends StatelessWidget {
  /// {@macro product_screen}
  const ProductScreen({required this.id, super.key});

  final Object? id;

  @override
  Widget build(BuildContext context) {
    const notFoundScreen = NotFoundScreen(
      message: 'Product is not found',
    );
    final productId = switch (id) {
      String id => int.tryParse(id),
      int id => id,
      _ => null,
    };
    if (productId == null) return notFoundScreen;
    final product = ShopScope.getProductById(context, productId);
    if (product == null) return notFoundScreen;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: CommonActions(),
        leading: const ShopBackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: CatalogBreadcrumbs(id: id.toString()),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // Product photos
            if (product.images.isNotEmpty)
              SliverPadding(
                padding:
                    ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 256,
                    child: _ProductPhotosListView(product: product),
                  ),
                ),
              ),

            SliverPadding(
              padding: ScaffoldPadding.of(context),
              sliver: const SliverToBoxAdapter(
                child: Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  height: 8,
                ),
              ),
            ),

            // Favorite button
            SliverPadding(
              padding: ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
              sliver: SliverToBoxAdapter(
                child: FavoriteButton(product: product),
              ),
            ),

            SliverPadding(
              padding: ScaffoldPadding.of(context),
              sliver: const SliverToBoxAdapter(
                child: Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  height: 8,
                ),
              ),
            ),

            // Product properties
            SliverPadding(
              padding: ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 4,
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    ProductProperty(title: 'Brand', value: product.brand),
                    ProductProperty(
                        title: 'Rating', value: product.rating.toString()),
                    ProductProperty(
                        title: 'Stock', value: product.stock.toString()),
                    ProductProperty(
                        title: 'Price', value: product.price.toString()),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: ScaffoldPadding.of(context),
              sliver: const SliverToBoxAdapter(
                child: Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  height: 8,
                ),
              ),
            ),

            // Product description
            SliverPadding(
              padding: ScaffoldPadding.of(context),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: 420,
                    child: Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
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
}

class _ProductPhotosListView extends StatefulWidget {
  const _ProductPhotosListView({
    required this.product,
  });

  final ProductEntity product;

  @override
  State<_ProductPhotosListView> createState() => _ProductPhotosListViewState();
}

class _ProductPhotosListViewState extends State<_ProductPhotosListView> {
  bool inProgress = false;
  late Timer? timer;
  late final FixedExtentScrollController controller;
  late int currentPage = widget.product.images.length ~/ 2;

  @override
  void initState() {
    currentPage = widget.product.images.length ~/ 2;
    controller = FixedExtentScrollController(initialItem: currentPage);
    _setUpTimer();
    controller.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    currentPage = controller.selectedItem;
    timer?.cancel();
    timer = null;
    timer = Timer(const Duration(seconds: 5), _setUpTimer);
  }

  void _setUpTimer() {
    if (!mounted) return;
    timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (widget.product.images.length < 2) return;
        if (!controller.hasClients) return;
        final newPage = currentPage + 1;
        animateTo(newPage > widget.product.images.length - 1 ? 0 : newPage);
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void animateTo(int index) {
    if (inProgress) return;
    if (index == controller.selectedItem) return;
    inProgress = true;
    controller
        .animateToItem(
          index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        )
        .whenComplete(() => inProgress = false)
        .ignore();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: ListWheelScrollView(
                controller: controller,
                itemExtent: 256,
                diameterRatio: 2.5,
                /* physics: const FixedExtentScrollPhysics(), */
                physics: const FixedExtentScrollPhysics(),
                children: widget.product.images
                    .mapIndexed<Widget>(
                      (idx, image) => RotatedBox(
                        quarterTurns: 1,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ProductImageScreen.show(
                                context,
                                id: widget.product.id,
                                index: idx,
                              );
                              HapticFeedback.mediumImpact().ignore();
                            },
                            child: Hero(
                              tag: 'product-${widget.product.id}-image-$idx',
                              child: Ink.image(
                                image: AssetImage(image),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .map<Widget>(
                      (child) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: child,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          SizedBox(
            height: 24,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (var i = 0; i < widget.product.images.length; i++)
                      MouseRegion(
                        onHover: (_) => animateTo(i),
                        child: GestureDetector(
                          onTap: () => animateTo(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SizedBox.square(
                              dimension: 16,
                              child: Material(
                                color: i == currentPage
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withAlpha(128),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}

class ProductProperty extends StatelessWidget {
  const ProductProperty({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: Chip(
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          avatar: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              title[0],
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          label: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '$title: ',
                ),
                TextSpan(
                  text: value,
                ),
              ],
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      );
}
