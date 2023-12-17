import 'package:example/src/feature/shop/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template favorite_button}
/// FavoriteButton widget
/// {@endtemplate}
class FavoriteButton extends StatelessWidget {
  /// {@macro favorite_button}
  const FavoriteButton({required this.product, super.key});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final mark = DateTime.now().millisecondsSinceEpoch % 2 == 0;
    //final mark = FavoriteScope.of(context).any((p) => p.id == product.id);
    return Center(
      child: SizedBox(
        width: 280,
        child: ElevatedButton.icon(
          onPressed: mark
              ? () {
                  //FavoriteScope.remove(context, product.id);
                  HapticFeedback.mediumImpact().ignore();
                }
              : () {
                  //FavoriteScope.add(context, product.id);
                  HapticFeedback.mediumImpact().ignore();
                },
          icon: mark
              ? const Icon(Icons.favorite, color: Colors.red)
              : const Icon(Icons.favorite_border, color: Colors.grey),
          style: ElevatedButton.styleFrom(
            backgroundColor: mark
                ? Theme.of(context).buttonTheme.colorScheme?.background
                : Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          label:
              Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
