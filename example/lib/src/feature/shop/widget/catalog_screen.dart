import 'package:example/src/common/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template catalog_tab}
/// CatalogTab widget.
/// {@endtemplate}
class CatalogTab extends StatelessWidget {
  /// {@macro catalog_tab}
  const CatalogTab({super.key});

  @override
  Widget build(BuildContext context) => OctopusNavigator.nested(
        defaultRoute: Routes.catalog,
      );
}

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
