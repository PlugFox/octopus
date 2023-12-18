import 'dart:math' as math;

import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:flutter/material.dart';

/// {@template signup_screen}
/// SignUpScreen widget.
/// {@endtemplate}
class SignUpScreen extends StatelessWidget {
  /// {@macro signup_screen}
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) => Title(
        title: 'Sign-Up',
        color: Theme.of(context).colorScheme.primary,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: math.max(16, (constraints.maxWidth - 620) / 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: Text(
                          'Sign-Up',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(height: 1),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const FormPlaceholder(),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: _SignUpScreen$Buttons(
                          cancel: () => Navigator.pop(context),
                          signUp: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _SignUpScreen$Buttons extends StatelessWidget {
  const _SignUpScreen$Buttons({
    required this.signUp,
    required this.cancel,
    super.key,
  });

  final void Function()? signUp;
  final void Function()? cancel;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: signUp,
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Sign-Up',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: FilledButton.tonalIcon(
              onPressed: cancel,
              icon: const Icon(Icons.cancel),
              label: const Text(
                'Cancel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
}
