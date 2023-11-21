import 'package:flutter/material.dart';

/// {@template product_screen}
/// ProductScreen widget.
/// {@endtemplate}
class ProductScreen extends StatelessWidget {
  /// {@macro product_screen}
  const ProductScreen({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Product'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Product'),
          ),
        ),
      );
}
