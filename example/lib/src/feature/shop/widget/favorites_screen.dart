import 'package:example/src/common/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template favorites_tab}
/// FavoritesTab widget.
/// {@endtemplate}
class FavoritesTab extends StatelessWidget {
  /// {@macro favorites_tab}
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) => const FavoritesScreen();
}

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
          leading: BackButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.maybePop(context);
                return;
              }
              // On back button pressed, close shop tabs
              Octopus.of(context).setState(
                (state) => state
                  ..removeWhere(
                    (route) => route.name == Routes.shop.name,
                  ),
              );
            },
          ),
        ),
        body: const SafeArea(
          child: Placeholder(),
        ),
      );
}
