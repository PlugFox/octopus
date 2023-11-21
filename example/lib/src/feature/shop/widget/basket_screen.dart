import 'package:flutter/material.dart';

/// {@template basket_screen}
/// BasketScreen widget.
/// {@endtemplate}
class BasketScreen extends StatelessWidget {
  /// {@macro basket_screen}
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Basket'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Basket'),
          ),
        ),
      );
}
