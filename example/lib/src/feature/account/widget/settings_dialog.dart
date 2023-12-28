import 'package:flutter/material.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsDialog extends StatelessWidget {
  /// {@macro settings_screen}
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: const Text('Settings'),
        content: const Text('Coming soon...'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
}
