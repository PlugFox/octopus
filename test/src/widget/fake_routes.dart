import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// Fake routes for testing.
enum FakeRoutes with OctopusRoute {
  home('home', title: 'Home'),
  shop('shop', title: 'Shop'),
  category('category', title: 'Category'),
  product('product', title: 'Product'),
  profile('profile', title: 'Profile');

  const FakeRoutes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) =>
      switch (this) {
        FakeRoutes.home => FakeScreen(
            FakeRoutes.home,
            arguments: node.arguments,
          ),
        FakeRoutes.shop => FakeScreen(
            FakeRoutes.shop,
            arguments: node.arguments,
          ),
        FakeRoutes.category => FakeScreen(
            FakeRoutes.category,
            arguments: node.arguments,
          ),
        FakeRoutes.product => FakeScreen(
            FakeRoutes.product,
            arguments: node.arguments,
          ),
        FakeRoutes.profile => FakeScreen(
            FakeRoutes.profile,
            arguments: node.arguments,
          ),
      };
}

/// FakeScreen widget for testing.
class FakeScreen extends StatelessWidget {
  const FakeScreen(
    this.route, {
    required this.arguments,
    super.key, // ignore: unused_element
  });

  final FakeRoutes route;

  final Map<String, String> arguments;

  String? get id => arguments['id'];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(route.title ?? route.name)),
        body: const SafeArea(
          child: Center(
            child: SizedBox.shrink(),
          ),
        ),
      );
}
