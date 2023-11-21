import 'package:flutter/material.dart';

/// {@template account_screen}
/// AccountScreen widget.
/// {@endtemplate}
class AccountScreen extends StatelessWidget {
  /// {@macro account_screen}
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Account'),
          ),
        ),
      );
}
