import 'dart:async';

import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/authentication/model/user.dart';
import 'package:octopus/octopus.dart';

/// Check routes always contain the home route at the first position.
/// Only exception only for not authenticated users.
class HomeGuard extends OctopusGuard {
  HomeGuard();

  @override
  FutureOr<OctopusState?> call(
    List<OctopusHistoryEntry> history,
    OctopusState state,
    Map<String, Object?> context,
  ) async {
    final authenticated = switch (context['user']) {
      User user => user.isAuthenticated,
      _ => false,
    };

    // If the user is not authenticated, do nothing.
    if (!authenticated) return state;

    final name = Routes.home.name;
    var counter = 0;
    state.visitChildNodes((child) {
      if (child.name == name) counter++;
      return true;
    });
    if (state.isNotEmpty && counter == 1 && state.children.first.name == name)
      return state;

    state.removeWhere((child) => child.name == name);
    state.children.insert(0, Routes.home.node());
    return state;
  }
}
