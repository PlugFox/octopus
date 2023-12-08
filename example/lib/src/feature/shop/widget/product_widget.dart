import 'package:flutter/material.dart';

/// {@template product_widget}
/// ProductWidget
/// {@endtemplate}
class ProductWidget extends StatelessWidget {
  /// {@macro product_widget}
  const ProductWidget({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Product'),
      );
}
