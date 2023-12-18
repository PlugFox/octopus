import 'dart:async';

import 'package:collection/collection.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:example/src/common/widget/not_found_screen.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/catalog_breadcrumbs.dart';
import 'package:example/src/feature/shop/widget/favorite_button.dart';
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

    /* Widget discountBanner(Widget child) => product.discountPercentage >= 15
        ? ClipRect(
            child: Banner(
              location: BannerLocation.topEnd,
              message: '${product.discountPercentage.round()}%',
              child: child,
            ),
          )
        : child; */

    return Scaffold(
      floatingActionButton: FavoriteButton(
        productId: productId,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // App bar
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              title: Text(product.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: CommonActions(),
              leading: const ShopBackButton(),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: SizedBox(
                  height: 48,
                  child: CatalogBreadcrumbs.product(id: productId),
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(top: 16),
            ),

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

            const _ProductDivider(),

            // Product title
            SliverPadding(
              padding: ScaffoldPadding.of(context).copyWith(bottom: 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: 16),
            ),

            // Product rating and price
            _ProductRatingAndPrice(product: product),

            /* // Favorite button
              SliverPadding(
                padding:
                    ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
                sliver: SliverToBoxAdapter(
                  child: FavoriteButton(product: product),
                ),
              ), */

            const SliverPadding(
              padding: EdgeInsets.only(bottom: 16),
            ),

            // Product tags
            const _ProductTags(),

            const _ProductDivider(),

            // Product properties
            _ProductProperties(product: product),

            const _ProductDivider(),

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

            const _ProductDivider(),

            // Product form
            SliverPadding(
              padding: ScaffoldPadding.of(context),
              sliver: const SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: 512,
                    child: FormPlaceholder(),
                  ),
                ),
              ),
            ),

            // Offset
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 42),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductRatingAndPrice extends StatelessWidget {
  const _ProductRatingAndPrice({
    required this.product,
    super.key, // ignore: unused_element
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context).copyWith(bottom: 8),
        sliver: SliverToBoxAdapter(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${product.rating} ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                      ),
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                color: const Color.fromARGB(160, 0, 255, 13),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: InkWell(
                  onTap: () {},
                  splashColor: const Color.fromARGB(160, 0, 255, 13),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: SizedBox(
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${product.price} \$',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                          ),
                          const SizedBox(width: 24),
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
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

class _ProductDivider extends StatelessWidget {
  const _ProductDivider({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context).copyWith(bottom: 16, top: 16),
        sliver: const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: CustomPaint(
              painter: _ProductDividerPainter(),
              child: SizedBox(height: 8),
            ),
          ),
        ),
      );
}

class _ProductDividerPainter extends CustomPainter {
  const _ProductDividerPainter({super.repaint}); // ignore: unused_element

  static final _paint = Paint()
    ..color = const Color(0x7FE0E0E0)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const offset = 16.0;
    canvas.drawLine(
      Offset(offset, size.height / 2),
      Offset(size.width - offset, size.height / 2),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_ProductDividerPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_ProductDividerPainter oldDelegate) => false;
}

class _ProductTags extends StatelessWidget {
  const _ProductTags({super.key}); // ignore: unused_element

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.horizontal,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              for (var i = 1; i < 5; i++)
                ActionChip(
                  onPressed: () {},
                  label: Text('Tag: $i'),
                  shape: const StadiumBorder(),
                ),
            ],
          ),
        ),
      );
}

class _ProductProperties extends StatelessWidget {
  const _ProductProperties({
    required this.product,
    super.key, // ignore: unused_element
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
        sliver: SliverFixedExtentList.list(
          itemExtent: 34,
          children: <Widget>[
            ProductProperty(title: 'Brand', value: product.brand),
            ProductProperty(title: 'Rating', value: product.rating.toString()),
            ProductProperty(title: 'Stock', value: product.stock.toString()),
            ProductProperty(title: 'Price', value: product.price.toString()),
            if (product.discountPercentage >= 1)
              ProductProperty(
                  title: 'Discount',
                  value: '${product.discountPercentage.round()}%'),
            const ProductProperty(title: 'Size', value: '0.0 x 0.0 x 0.0 cm'),
            const ProductProperty(title: 'Weight', value: '0.0 kg'),
            const ProductProperty(title: 'Article', value: '1234567890'),
            const ProductProperty(title: 'Barcode', value: '|||||||||||||||'),
            const ProductProperty(title: 'Country', value: 'China'),
            const ProductProperty(title: 'Color', value: 'Black'),
            const ProductProperty(title: 'Material', value: 'Plastic'),
            const ProductProperty(title: 'Warranty', value: '1 year'),
          ],
        ),
      );
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
  Widget build(BuildContext context) => ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.purple,
            Colors.transparent,
            Colors.transparent,
            Colors.purple
          ],
          stops: <double>[
            0,
            0.25,
            0.75,
            1
          ], // 25% purple, 50% transparent, 25% purple
        ).createShader(rect),
        blendMode: BlendMode.dstOut,
        child: Column(
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
                                  fit: BoxFit.cover,
                                  height: 256,
                                  width: 256,
                                  alignment: Alignment.center,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
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
        ),
      );
}

class ProductProperty extends StatelessWidget {
  const ProductProperty({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          height: 34,
          width: 512,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                '$title: '.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Expanded(
                child: CustomPaint(
                  painter: _ProductPropertyDotsPainter(),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      );
}

class _ProductPropertyDotsPainter extends CustomPainter {
  const _ProductPropertyDotsPainter({super.repaint}); // ignore: unused_element

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const radius = 1.0;
    const space = 5.0;
    final count = (size.width - radius * 2) ~/ (radius * 2 + space);
    final offset = (size.width - count * (radius * 2 + space)) / 2;
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(offset + radius + i * (radius * 2 + space), size.height / 2 + 1),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProductPropertyDotsPainter oldDelegate) =>
      false;

  @override
  bool shouldRebuildSemantics(
          covariant _ProductPropertyDotsPainter oldDelegate) =>
      false;
}
