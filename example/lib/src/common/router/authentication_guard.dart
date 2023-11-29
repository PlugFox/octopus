import 'dart:async';

import 'package:example/src/feature/authentication/model/user.dart';
import 'package:octopus/octopus.dart';

/// A router guard that checks if the user is authenticated.
class AuthenticationGuard extends OctopusGuard {
  AuthenticationGuard({
    required FutureOr<User> Function() getUser,
    required Set<String> routes,
    required OctopusState signinNavigation,
    required OctopusState homeNavigation,
    super.refresh,
  })  : _getUser = getUser,
        _routes = routes,
        _lastNavigation = homeNavigation,
        _signinNavigation = signinNavigation;

  /// Get the current user.
  final FutureOr<User> Function() _getUser;

  /// Routes names that stand for the authentication routes.
  final Set<String> _routes;

  /// The navigation to use when the user is not authenticated.
  final OctopusState _signinNavigation;

  /// The navigation to use when the user is authenticated.
  OctopusState _lastNavigation;

  @override
  FutureOr<OctopusState?> call(
    List<OctopusState> history,
    OctopusState state,
  ) async {
    final user = await _getUser(); // Get the current user.
    final isAuthNav =
        state.children.any((child) => _routes.contains(child.name));
    if (isAuthNav) {
      // New state is an authentication navigation.
      if (user.isAuthenticated) {
        // User authenticated.
        // Remove any navigation that is an authentication navigation.
        state.removeWhere((child) => _routes.contains(child.name));
        // Restore the last navigation when the user is authenticated
        // if the state contains only the authentication routes.
        return state.isEmpty ? _lastNavigation : state;
      } else {
        // User not authenticated.
        // Remove any navigation that is not an authentication navigation.
        state.removeWhere((child) => !_routes.contains(child.name));
        // Add the signin navigation if the state is empty.
        // Or return the state if it contains the signin navigation.
        return state.isEmpty ? _signinNavigation : state;
      }
    } else {
      // New state is not an authentication navigation.
      if (user.isAuthenticated) {
        // User authenticated.
        // Save the current navigation as the last navigation.
        _lastNavigation = state;
        return super.call(history, state);
      } else {
        // User not authenticated.
        // Replace the current navigation with the signin navigation.
        return _signinNavigation;
      }
    }
  }
}
