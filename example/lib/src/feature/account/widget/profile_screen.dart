import 'package:flutter/material.dart';

/// {@template profile_screen}
/// ProfileScreen widget.
/// {@endtemplate}
class ProfileScreen extends StatelessWidget {
  /// {@macro profile_screen}
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Profile'),
          ),
        ),
      );
}
