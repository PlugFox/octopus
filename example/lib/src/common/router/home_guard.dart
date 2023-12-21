import 'dart:async';

import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/authentication/model/user.dart';
import 'package:octopus/octopus.dart';

/// Check routes always contain the home route at the first position.
/// Only exception for not authenticated users.
class HomeGuard extends OctopusGuard {
  HomeGuard();

  @override
  FutureOr<OctopusState?> call(
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
    if (state.children.first.name != Routes.home.name) return _fix(state);
    final homeCount =
        state.fold<int>(0, (v, n) => n.name == Routes.home.name ? v + 1 : v);
    if (homeCount != 1) return _fix(state);
    return state;
  }

  /// Change the state of the nested navigation.
  OctopusState _fix(OctopusState$Mutable state) => state
    ..removeWhere((child) => child.name == Routes.home.name)
    ..children.insert(0, Routes.home.node());
}
