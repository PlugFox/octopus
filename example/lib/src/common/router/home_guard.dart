import 'dart:async';

import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/authentication/model/user.dart';
import 'package:octopus/octopus.dart';

/// Check routes always contain the home route at the first position.
/// Only exception for not authenticated users.
class HomeGuard extends OctopusGuard {
  HomeGuard();

  static final String _homeName = Routes.home.name;

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) {
    // If the user is not authenticated, do nothing.
    // The home route should not be in the state.
    if (context['user'] case User user) if (!user.isAuthenticated) return state;

    // Home route should be the first route in the state
    // and should be only one in whole state.
    if (state.isEmpty) return _fix(state);
    final count = state.findAllByName(_homeName).length;
    if (count != 1) return _fix(state);
    if (state.children.first.name != _homeName) return _fix(state);
    return state;
  }

  /// Change the state of the nested navigation.
  OctopusState _fix(OctopusState$Mutable state) => state
    ..clear()
    ..putIfAbsent(_homeName, () => Routes.home.node());
}
