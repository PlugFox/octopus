import 'dart:async';

import 'package:flutter/material.dart';
import 'package:octopus/src/state/state.dart' show OctopusState;

/// Guard for the router.
///
/// {@template guard}
/// This is good place for checking permissions, authentication, etc.
///
/// Return the new state or null to cancel navigation.
/// If the returned state is null or throw an error,
/// the router will not change the state at all.
///
/// You should return the same state if you don't want to change it and
/// continue navigation.
///
/// You should return the new state if you want to change it and
/// continue navigation.
///
/// You should return null if you want to cancel navigation.
///
/// If something changed in app state, you should notify the guard
/// and router rerun the all guards with current state.
/// {@endtemplate}
abstract interface class IOctopusGuard implements Listenable {
  /// Called when the [OctopusState] changes.
  ///
  /// [history] is the history of the [OctopusState] states.
  /// [state] is the expected new state.
  ///
  /// Return the new state or null to cancel navigation
  /// or [state] to continue navigation.
  ///
  /// DO NOT USE [notifyListeners] IN THIS METHOD TO AVOID INFINITE LOOP!
  ///
  /// {@macro guard}
  FutureOr<OctopusState?> call(List<OctopusState> history, OctopusState state);
}

/// {@macro guard}
class OctopusGuard with ChangeNotifier implements IOctopusGuard {
  /// {@macro guard}
  OctopusGuard();

  @override
  FutureOr<OctopusState?> call(
    List<OctopusState> history,
    OctopusState state,
  ) =>
      state;
}
