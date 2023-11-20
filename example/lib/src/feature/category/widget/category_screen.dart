import 'package:flutter/material.dart';

/// {@template category_screen}
/// CategoryScreen widget.
/// {@endtemplate}
class CategoryScreen extends StatelessWidget {
  /// {@macro category_screen}
  const CategoryScreen({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Category'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Category'),
          ),
        ),
      );
}
