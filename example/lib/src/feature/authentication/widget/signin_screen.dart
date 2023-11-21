import 'package:flutter/material.dart';

/// {@template signin_screen}
/// SignInScreen widget.
/// {@endtemplate}
class SignInScreen extends StatelessWidget {
  /// {@macro signin_screen}
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sign-In'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Sign-In'),
          ),
        ),
      );
}
