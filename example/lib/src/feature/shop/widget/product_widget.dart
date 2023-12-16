import 'package:flutter/material.dart';

/// {@template product_widget}
/// ProductWidget
/// {@endtemplate}
class ProductWidget extends StatefulWidget {
  /// {@macro product_widget}
  const ProductWidget({required this.id, super.key});

  final String? id;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Product'),
      );
}
