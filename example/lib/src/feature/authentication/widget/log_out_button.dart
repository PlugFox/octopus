import 'package:example/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template log_out_button}
/// LogOutButton widget
/// {@endtemplate}
class LogOutButton extends StatelessWidget {
  /// {@macro log_out_button}
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.logout),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          AuthenticationScope.signOut(context);
          HapticFeedback.mediumImpact().ignore();
        },
      );
}
