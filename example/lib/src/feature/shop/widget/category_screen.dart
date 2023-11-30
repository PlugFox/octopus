import 'package:flutter/material.dart';

/// {@template category_screen}
/// CategoryScreen.
/// {@endtemplate}
class CategoryScreen extends StatelessWidget {
  /// {@macro category_screen}
  const CategoryScreen({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Category'),
      );
}
