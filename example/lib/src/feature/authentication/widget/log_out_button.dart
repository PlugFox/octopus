import 'package:example/src/common/localization/localization.dart';
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
        tooltip: Localization.of(context).logOutButton,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.logout, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    Localization.of(context).logOutButton,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          height: 1,
                        ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            content: Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              SizedBox(
                height: 48,
                width: 128,
                child: FilledButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(Localization.of(context).logOutButton),
                  onPressed: () {
                    AuthenticationScope.signOut(context);
                    HapticFeedback.mediumImpact().ignore();
                  },
                ),
              ),
              SizedBox(
                height: 48,
                width: 128,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: Text(Localization.of(context).cancelButton),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
}
