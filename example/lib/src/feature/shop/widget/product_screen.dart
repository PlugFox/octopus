import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:example/src/common/constant/config.dart';
import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/util/color_util.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:example/src/common/widget/not_found_screen.dart';
import 'package:example/src/common/widget/outlined_text.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/catalog_breadcrumbs.dart';
import 'package:example/src/feature/shop/widget/favorite_button.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octopus/octopus.dart';

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
                child: Center(
                  child: OutlinedText(
                    product.title,
                    maxLines: 3,
                    fillColor: Theme.of(context).colorScheme.surface,
                    strokeColor: Colors.black,
                    strokeWidth: 6,
                    style: GoogleFonts.coiny(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      letterSpacing: 1,
                      shadows: <Shadow>[
                        const BoxShadow(
                          color: Colors.black12,
                          offset: Offset(9, 7),
                          blurRadius: 2,
                          blurStyle: BlurStyle.solid,
                        ),
                        const BoxShadow(
                          color: Colors.black12,
                          offset: Offset(9, 7),
                          blurRadius: 12,
                          blurStyle: BlurStyle.solid,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: 16),
            ),

            // Product rating and price
            _ProductRatingAndPrice(product: product),

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
                  child: _ProductStars(rating: product.rating),
                ),
              ),
              Card(
                elevation: 2,
                color: const Color.fromARGB(160, 0, 255, 13),
                margin: const EdgeInsets.all(4),
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Center(
                        child: DefaultTextStyle(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                            shadows: <Shadow>[
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset.zero,
                                blurRadius: 1,
                                blurStyle: BlurStyle.solid,
                              ),
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset.zero,
                                blurRadius: 2,
                                blurStyle: BlurStyle.solid,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  r'$',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  product.price.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: SizedBox(
                                  width: 42,
                                  height: 32,
                                  child: Stack(
                                    children: <Widget>[
                                      const Positioned(
                                        bottom: 0,
                                        left: 0,
                                        width: 24,
                                        height: 24,
                                        child: Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                          size: 24,
                                          shadows: [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset.zero,
                                              blurRadius: 1.5,
                                              blurStyle: BlurStyle.solid,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 14,
                                        width: 16,
                                        height: 16,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '1',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                height: 1,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        bottom: 0,
                                        right: 0,
                                        width: 24,
                                        height: 24,
                                        child: Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 24,
                                          shadows: [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset.zero,
                                              blurRadius: 1.5,
                                              blurStyle: BlurStyle.solid,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _ProductStars extends StatefulWidget {
  const _ProductStars({
    required this.rating,
    super.key, // ignore: unused_element
  });

  final double rating;

  @override
  State<_ProductStars> createState() => _ProductStarsState();
}

class _ProductStarsState extends State<_ProductStars>
    with SingleTickerProviderStateMixin {
  static const circleRadius = 32.0;
  static const iconsSize = 24.0;
  late final AnimationController _controller;
  final List<Widget> _icons = <Widget>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Запускает анимацию на повторение
    _rebuildIcons();
  }

  @override
  void didUpdateWidget(covariant _ProductStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildIcons();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rebuildIcons() {
    _icons.clear();
    final rating = widget.rating;
    final rating10 = (rating * 2).round();
    for (var r = 1; r < 11; r += 2) {
      if (rating10 > r) {
        _icons.add(
          const Icon(
            Icons.star,
            color: Colors.deepOrange,
            size: iconsSize,
          ),
        );
      } else if (rating10 == r) {
        _icons.add(
          const Icon(
            Icons.star_half,
            color: Colors.orange,
            size: iconsSize,
          ),
        );
      } else {
        _icons.add(
          const Icon(
            Icons.star_border,
            color: Colors.blueGrey,
            size: iconsSize,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rating = widget.rating;

    return RepaintBoundary(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              rating.toStringAsFixed(1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.coiny(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 0,
              ),
            ),
            ..._icons.mapIndexed(
              (i, icon) => AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  var angle =
                      2 * math.pi / 5 * i + (2 * math.pi * _controller.value);
                  return Transform.translate(
                    offset: Offset(
                      circleRadius * math.cos(angle),
                      circleRadius * math.sin(angle),
                    ),
                    child: _icons[i],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _ProductTags extends StatefulWidget {
  const _ProductTags({super.key}); // ignore: unused_element
  @override
  State<_ProductTags> createState() => _ProductTagsState();
}

class _ProductTagsState extends State<_ProductTags> {
  final count = math.Random().nextInt(4) + 2;
  late final colors = ColorUtil.getColors(count);
  // ignore: unused_element
  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context).copyWith(bottom: 8, top: 8),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.horizontal,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              for (var i = 0; i < colors.length; i++)
                _ProductTag('Tag', 'Value ${i + 1}', color: colors[i]),
            ],
          ),
        ),
      );
}

class _ProductTag extends StatelessWidget {
  const _ProductTag(
    this.k,
    this.v, {
    required this.color,
    super.key, // ignore: unused_element
  });

  final Color color;
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 128,
        height: 32,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: Theme.of(context).colorScheme.surface,
            border: const Border.fromBorderSide(
              BorderSide(
                color: Colors.black,
                width: .5,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 42,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                    border: const Border.fromBorderSide(
                      BorderSide(
                        color: Colors.black,
                        width: .5,
                      ),
                    ),
                  ),
                  child: Center(
                    child: OutlinedText(
                      k.toUpperCase(),
                      maxLines: 1,
                      fillColor: Colors.white,
                      strokeColor: Colors.black,
                      strokeWidth: .5,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: const Alignment(-0.25, 0),
                  child: Text(
                    v,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
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

  ImageProvider<Object> _getImageProvider(String path) =>
      (!kIsWeb || Config.environment.isDevelopment
          ? AssetImage(path)
          : NetworkImage('/$path')) as ImageProvider<Object>;

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
            0.15,
            0.85,
            1
          ], // 15% purple, 70% transparent, 15% purple
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
                                context.octopus.push(
                                  Routes.productImageDialog,
                                  arguments: <String, String>{
                                    'id': widget.product.id.toString(),
                                    'idx': idx.toString(),
                                  },
                                );
                                HapticFeedback.mediumImpact().ignore();
                              },
                              child: Hero(
                                tag: 'product-${widget.product.id}-image-$idx',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink.image(
                                    image: _getImageProvider(image),
                                    fit: BoxFit.cover,
                                    height: 256,
                                    width: 256,
                                    alignment: Alignment.center,
                                  ),
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
