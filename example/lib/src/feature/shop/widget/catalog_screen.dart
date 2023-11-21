import 'package:flutter/material.dart';

/// {@template catalog_screen}
/// CatalogScreen widget.
/// {@endtemplate}
class CatalogScreen extends StatelessWidget {
  /// {@macro catalog_screen}
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Catalog'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Catalog'),
          ),
        ),
      );
}
