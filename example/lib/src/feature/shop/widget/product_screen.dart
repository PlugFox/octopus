import 'package:example/src/feature/shop/widget/product_widget.dart';
import 'package:flutter/material.dart';

/// {@template product_screen}
/// ProductScreen widget.
/// {@endtemplate}
class ProductScreen extends StatelessWidget {
  /// {@macro product_screen}
  const ProductScreen({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) => ProductWidget(id: id);
}
