import 'package:flutter/material.dart';

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
                onTap: () {},
              ),
              ListTile(
                title: const Text('Gallery'),
                subtitle: const Text('Gallery description'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Account'),
                subtitle: const Text('Account description'),
                onTap: () {},
              ),
            ],
          ),
        ),
      );
}
