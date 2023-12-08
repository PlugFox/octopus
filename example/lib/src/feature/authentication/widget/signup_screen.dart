import 'package:flutter/material.dart';

/// {@template signup_screen}
/// SignUpScreen widget.
/// {@endtemplate}
class SignUpScreen extends StatelessWidget {
  /// {@macro signup_screen}
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sign-Up'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Sign-Up'),
          ),
        ),
      );
}
