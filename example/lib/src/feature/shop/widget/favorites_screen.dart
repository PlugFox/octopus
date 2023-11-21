import 'package:flutter/material.dart';

/// {@template favorites_screen}
/// FavoritesScreen widget.
/// {@endtemplate}
class FavoritesScreen extends StatelessWidget {
  /// {@macro favorites_screen}
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Favorites'),
          ),
        ),
      );
}
