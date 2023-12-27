import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:octopus/src/controller/config.dart';
import 'package:octopus/src/controller/guard.dart';
import 'package:octopus/src/controller/navigator/controller.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/controller/singleton.dart';
import 'package:octopus/src/controller/typedefs.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/widget/inherited_octopus.dart';

/// {@template octopus}
/// The main class of the package.
/// Router configuration is provided by the [routes] parameter.
/// {@endtemplate}
abstract interface class Octopus {
  /// {@macro octopus}
  factory Octopus({
    required List<OctopusRoute> routes,
    OctopusRoute? defaultRoute,
    List<IOctopusGuard>? guards,
    OctopusState? initialState,
    List<OctopusHistoryEntry>? history,
    Codec<RouteInformation, OctopusState>? codec,
    String? restorationScopeId,
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    NotFoundBuilder? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) = Octopus$NavigatorImpl;

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus? maybeOf(BuildContext context) =>
      InheritedOctopus.maybeOf(context, listen: false)?.octopus;

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus of(BuildContext context) =>
      InheritedOctopus.of(context, listen: false).octopus;

  /// Receives the current [OctopusState] instance from the elements tree.
  static OctopusState$Immutable stateOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      InheritedOctopus.of(context, listen: true).state;

  /// Receives the last initializated [Octopus] instance.
  static Octopus get instance =>
      $octopusSingletonInstance ?? _throwOctopusNotInitialized();
  static Never _throwOctopusNotInitialized() =>
      throw Exception('Octopus is not initialized yet.');

  /// A convenient bundle to configure a [Router] widget.
  abstract final OctopusConfig config;

  /// {@nodoc}
  @Deprecated('Renamed to "observer".')
  OctopusStateObserver get stateObserver;

  /// State observer,
  /// which can be used to listen to changes in the [OctopusState].
  OctopusStateObserver get observer;

  /// Current state.
  OctopusState$Immutable get state;

  /// History of the [OctopusState] states.
  List<OctopusHistoryEntry> get history;

  /// Completes when processing queue is empty
  /// and all transactions are completed.
  /// This is mean controller is ready to use and in a idle state.
  Future<void> get processingCompleted;

  /// Whether the controller is currently processing a tasks.
  bool get isProcessing;

  /// Whether the controller is currently idle.
  bool get isIdle;

  /// Set new state and rebuild the navigation tree if needed.
  ///
  /// Better to use [transaction] method to change multiple states
  /// at once synchronously at the same time and merge changes into transaction.
  Future<void> setState(
      OctopusState Function(OctopusState$Mutable state) change);

  /// Navigate to the specified location.
  Future<void> navigate(String location);

  /// Execute a synchronous transaction.
  /// For example you can use it to change multiple states at once and
  /// combine them into one change.
  ///
  /// [change] is a function that takes the current state as an argument
  /// and returns a new state.
  /// [priority] is used to determine the order of execution of transactions.
  /// The higher the priority, the earlier the transaction will be executed.
  /// If the priority is not specified, the transaction will be executed
  /// in the order in which it was added.
  Future<void> transaction(
    OctopusState Function(OctopusState$Mutable state) change, {
    int? priority,
  });

  /// Push a new top route to the navigation stack
  /// with the specified [arguments].
  Future<void> push(OctopusRoute route, {Map<String, String>? arguments});

  /// Push a new top route to the navigation stack
  /// with the specified [arguments].
  Future<void> pushNamed(
    String name, {
    Map<String, String>? arguments,
  });

  /// Push multiple routes to the navigation stack.
  Future<void> pushAll(
      List<({OctopusRoute route, Map<String, String>? arguments})> routes);

  /// Push multiple routes to the navigation stack.
  Future<void> pushAllNamed(
    List<({String name, Map<String, String>? arguments})> routes,
  );

  /// Mutate all nodes with a new one. From leaf to root.
  Future<void> replaceAll(
    OctopusNode Function(OctopusNode$Mutable) fn, {
    bool recursive = true,
  });

  /// Replace the last top route in the navigation stack with a new one.
  Future<OctopusNode> upsertLast(
    OctopusRoute route, {
    Map<String, String>? arguments,
  });

  /// Replace the last top route in the navigation stack with a new one.
  Future<OctopusNode> upsertLastNamed(
    String name, {
    Map<String, String>? arguments,
  });

  /// Pop a one of the top routes from the navigation stack.
  /// If the stack contains only one route, close the application.
  Future<OctopusNode?> pop();

  /// Pop a one of the top routes from the navigation stack.
  /// If the stack contains only one route, nothing will happen.
  Future<OctopusNode?> maybePop();

  /// Pop all except the first route from the navigation stack.
  /// If the stack contains only one route, nothing will happen.
  /// Usefull to go back to the "home" route.
  Future<void> popAll();

  /// Pop all routes from the navigation stack until the predicate is true.
  /// If the test is not satisfied,
  /// the node is not removed and the walk is stopped.
  /// [true] - remove node
  /// [false] - stop walk and keep node
  Future<List<OctopusNode>> popUntil(bool Function(OctopusNode node) predicate);

  /// Get a route by name.
  OctopusRoute? getRouteByName(String name);

  /// Update state arguments
  Future<void> setArguments(void Function(Map<String, String> args) change);
}
