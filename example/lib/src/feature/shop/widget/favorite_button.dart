import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template favorite_button}
/// FavoriteButton widget.
/// {@endtemplate}
class FavoriteButton extends StatelessWidget {
  /// {@macro favorite_button}
  const FavoriteButton({required this.productId, super.key});

  final ProductID productId;

  @override
  Widget build(BuildContext context) {
    final status = ShopScope.isFavorite(context, productId, listen: true);
    return FloatingActionButton(
      onPressed: () {
        if (status) {
          ShopScope.removeFavorite(context, productId);
          HapticFeedback.lightImpact().ignore();
        } else {
          ShopScope.addFavorite(context, productId);
          HapticFeedback.mediumImpact().ignore();
        }
      },
      backgroundColor: status
          ? Theme.of(context).buttonTheme.colorScheme?.background
          : Theme.of(context).primaryColor,
      shape: status
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: Theme.of(context).buttonTheme.colorScheme?.primary ??
                    Colors.transparent,
              ),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.bounceInOut,
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: status
            ? const Icon(
                Icons.favorite,
                key: ValueKey('favorite'),
                color: Colors.red,
                size: 36,
              )
            : const Icon(
                Icons.favorite_border,
                key: ValueKey('favorite_border'),
                color: Colors.grey,
                size: 24,
              ),
      ),
    );
  }
}
