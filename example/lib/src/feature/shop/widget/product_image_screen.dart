import 'package:example/src/common/widget/not_found_screen.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

/// {@template photo_image_screen}
/// ProductImageViewScreen widget
/// {@endtemplate}
class ProductImageScreen extends StatelessWidget {
  /// {@macro photo_image_screen}
  const ProductImageScreen._({
    required this.id,
    required this.idx,
    super.key, // ignore: unused_element
  });

  /// Product id
  final Object? id;

  /// Image index in product images
  final Object? idx;

  /// Show anonymous route screen
  static Future<void> show(
    BuildContext context, {
    required ProductID id,
    required int index,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = PageRouteBuilder<void>(
      pageBuilder: (context, _, __) => BackButtonListener(
        onBackButtonPressed: navigator.maybePop,
        child: ProductImageScreen._(id: id, idx: index),
      ),
      transitionsBuilder: (context, animation, secondayAnimation, child) =>
          ScaleTransition(
        scale: Tween<double>(begin: 1.25, end: 1).animate(animation),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        ),
      ),
    );
    return navigator.push<void>(route);
  }

  @override
  Widget build(BuildContext context) {
    const notFoundScreen = NotFoundScreen(
      message: 'Image is not found',
    );
    final productId = switch (id) {
      String id => int.tryParse(id),
      int id => id,
      _ => null,
    };
    if (productId == null) return notFoundScreen;
    final product = ShopScope.getProductById(context, productId);
    if (product == null) return notFoundScreen;
    final index = switch (idx) {
      String idx => int.tryParse(idx),
      int idx => idx,
      _ => null,
    };
    if (index == null) return notFoundScreen;
    if (index < 0 || index >= product.images.length) return notFoundScreen;
    final image = product.images[index];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PhotoView.customChild(
                basePosition: Alignment.center,
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: 3.0,
                enableRotation: false,
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                child: SafeArea(
                  child: Center(
                    child: Hero(
                      tag: 'product-${product.id}-image-$index',
                      child: Image.asset(
                        image,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (Navigator.canPop(context)) const _ProductImageBackButton(),
          ],
        ),
      ),
    );
  }
}

class _ProductImageBackButton extends StatelessWidget {
  // ignore: unused_element
  const _ProductImageBackButton({super.key}) : _isLarge = false;

  // ignore: unused_element
  const _ProductImageBackButton.large({super.key}) : _isLarge = true;

  final bool _isLarge;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox.square(
              dimension: _isLarge ? 82 : 48,
              child: Material(
                color: Theme.of(context).colorScheme.secondary,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.maybePop(context);
                    HapticFeedback.mediumImpact().ignore();
                  },
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.fullscreen_exit,
                    size: _isLarge ? 48 : 32,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
