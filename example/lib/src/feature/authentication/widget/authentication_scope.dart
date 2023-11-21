import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/feature/authentication/controller/authentication_controller.dart';
import 'package:example/src/feature/authentication/controller/authentication_state.dart';
import 'package:example/src/feature/authentication/model/sign_in_data.dart';
import 'package:example/src/feature/authentication/model/user.dart';
import 'package:flutter/widgets.dart';

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthenticationScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthenticationScope({
    required this.child,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Get the current [User]
  static User userOf(BuildContext context, {bool listen = true}) =>
      _InheritedAuthenticationScope.of(context, listen: listen).state.user;

  /// Sign-In
  static void signIn(BuildContext context, SignInData data) =>
      _InheritedAuthenticationScope.of(context, listen: false).signIn(data);

  /// Sign-Out
  static void signOut(BuildContext context) =>
      _InheritedAuthenticationScope.of(context, listen: false).signOut();

  @override
  State<AuthenticationScope> createState() => _AuthenticationScopeState();
}

/// State for widget AuthenticationScope.
class _AuthenticationScopeState extends State<AuthenticationScope> {
  late final AuthenticationController controller;

  @override
  void initState() {
    super.initState();
    controller = Dependencies.of(context).authenticationController;
    controller.addListener(_listener);
  }

  void _listener() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InheritedAuthenticationScope(
        controller: controller,
        state: controller.state,
        child: widget.child,
      );
}

/// Inherited widget for quick access in the element tree.
class _InheritedAuthenticationScope extends InheritedWidget {
  const _InheritedAuthenticationScope({
    required this.controller,
    required this.state,
    required super.child,
  });

  final AuthenticationController controller;
  final AuthenticationState state;

  static AuthenticationController? maybeOf(BuildContext context,
          {bool listen = true}) =>
      (listen
              ? context.dependOnInheritedWidgetOfExactType<
                  _InheritedAuthenticationScope>()
              : context.getInheritedWidgetOfExactType<
                  _InheritedAuthenticationScope>())
          ?.controller;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a _InheritedAuthenticationScope of the exact type',
        'out_of_scope',
      );

  static AuthenticationController of(BuildContext context,
          {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedAuthenticationScope oldWidget) =>
      !identical(oldWidget.state, state);
}
