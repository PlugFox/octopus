import 'package:example/src/common/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                title: const Text('Shop'),
                subtitle: const Text('Shop description'),
                onTap: () => Octopus.of(context)
                    .setState((state) => state..add(Routes.shop.node())),
              ),
              ListTile(
                title: const Text('Gallery'),
                subtitle: const Text('Gallery description'),
                onTap: () => Octopus.of(context)
                    .setState((state) => state..add(Routes.gallery.node())),
              ),
              ListTile(
                title: const Text('Account'),
                subtitle: const Text('Account description'),
                onTap: () => Octopus.of(context)
                    .setState((state) => state..add(Routes.account.node())),
              ),
            ],
          ),
        ),
      );
}
