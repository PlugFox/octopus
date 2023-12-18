import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsDialog extends StatelessWidget {
  /// {@macro settings_screen}
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Coming soon...'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Octopus.maybePop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
}
