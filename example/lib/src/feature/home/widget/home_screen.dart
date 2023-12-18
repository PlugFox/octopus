import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
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
          leading: const SizedBox.shrink(),
          actions: CommonActions(),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                title: const Text('Shop'),
                subtitle: const Text('Explore nested navigation'),
                onTap: () => Octopus.push(context, Routes.shop),
              ),
              ListTile(
                title: const Text('Gallery'),
                subtitle: const Text('Gallery description'),
                onTap: () => Octopus.push(context, Routes.gallery),
              ),
            ],
          ),
        ),
      );
}
