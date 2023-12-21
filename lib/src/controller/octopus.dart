import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:octopus/src/controller/delegate.dart';
import 'package:octopus/src/controller/guard.dart';
import 'package:octopus/src/controller/information_parser.dart';
import 'package:octopus/src/controller/information_provider.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/util/state_util.dart';
import 'package:octopus/src/widget/navigator.dart';

/// {@template octopus}
/// The main class of the package.
/// Router configuration is provided by the [routes] parameter.
/// {@endtemplate}
abstract base class Octopus {
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
  }) = _OctopusImpl;

  Octopus._({required this.config}) {
    _$octopusSingletonInstance = this;
  }

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus? maybeOf(BuildContext context) =>
      OctopusNavigator.maybeOf(context);

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus of(BuildContext context) => OctopusNavigator.of(context);

  /// Receives the last initializated [Octopus] instance.
  static Octopus get instance =>
      _$octopusSingletonInstance ?? _throwOctopusNotInitialized();
  static Octopus? _$octopusSingletonInstance;
  static Never _throwOctopusNotInitialized() =>
      throw Exception('Octopus is not initialized yet.');

  /// A convenient bundle to configure a [Router] widget.
  final OctopusConfig config;

  /// State observer,
  /// which can be used to listen to changes in the [OctopusState].
  OctopusStateObserver get stateObserver;

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

  /// Push a new top route to the navigation stack.
  Future<void> push(OctopusRoute route);

  /// Push a new top route to the navigation stack.
  Future<void> pushNamed(
    String name, {
    Map<String, String>? arguments,
  });

  /// Push multiple routes to the navigation stack.
  Future<void> pushAll(List<OctopusRoute> routes);

  /// Push multiple routes to the navigation stack.
  Future<void> pushAllNamed(
    List<({String name, Map<String, String>? arguments})> routes,
  );

  /// Replace the last top route in the navigation stack with a new one.
  Future<void> replace(OctopusRoute route);

  /// Replace the last top route in the navigation stack with a new one.
  Future<void> replaceNamed(
    String name, {
    Map<String, String>? arguments,
  });

  /// Pop a one of the top routes from the navigation stack.
  /// If the stack contains only one route, nothing will happen.
  Future<void> maybePop();

  /// Pop all except the first route from the navigation stack.
  Future<void> popAll();

  /// Pop all routes from the navigation stack until the predicate is true.
  Future<void> popUntil(bool Function(OctopusNode node) predicate);
}

/// {@nodoc}
final class _OctopusImpl extends Octopus
    with _OctopusDelegateOwner, _OctopusMethodsMixin, _OctopusTransactionMixin {
  /// {@nodoc}
  factory _OctopusImpl({
    required List<OctopusRoute> routes,
    OctopusRoute? defaultRoute,
    List<IOctopusGuard>? guards,
    OctopusState? initialState,
    List<OctopusHistoryEntry>? history,
    Codec<RouteInformation, OctopusState>? codec,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    NotFoundBuilder? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    assert(routes.isNotEmpty, 'Routes list should contain at least one route');
    final list = List<OctopusRoute>.of(routes);
    defaultRoute ??= list.firstOrNull;
    if (defaultRoute == null) {
      final error = StateError('Routes list should contain at least one route');
      onError?.call(error, StackTrace.current);
      throw error;
    }
    assert(
      list.map<String>((e) => e.name).toSet().length == list.length,
      'Routes list should not contain duplicate names',
    );
    final routeInformationProvider = OctopusInformationProvider();
    final backButtonDispatcher = RootBackButtonDispatcher();
    final routeInformationParser = OctopusInformationParser(codec: codec);
    final routesTable = Map<String, OctopusRoute>.unmodifiable(
      <String, OctopusRoute>{
        for (final route in routes) route.name: route,
      },
    );
    final routerDelegate = OctopusDelegate(
      initialState: initialState?.freeze() ??
          OctopusState$Immutable(
            children: <OctopusNode>[defaultRoute.node()],
            arguments: const <String, String>{},
          ),
      history: history,
      routes: routesTable,
      defaultRoute: defaultRoute,
      guards: guards,
      restorationScopeId: restorationScopeId,
      observers: observers,
      transitionDelegate: transitionDelegate,
      notFound: notFound,
      onError: onError,
    );
    final controller = _OctopusImpl._(
      routes: routesTable,
      routeInformationProvider: routeInformationProvider,
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher,
    );
    routerDelegate.$controller = WeakReference<Octopus>(controller);
    return controller;
  }

  _OctopusImpl._({
    required Map<String, OctopusRoute> routes,
    required OctopusDelegate routerDelegate,
    required OctopusInformationProvider routeInformationProvider,
    required OctopusInformationParser routeInformationParser,
    required BackButtonDispatcher backButtonDispatcher,
  }) : super._(
          config: OctopusConfig(
            routes: routes,
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            backButtonDispatcher: backButtonDispatcher,
          ),
        );

  @override
  OctopusStateObserver get stateObserver => config.routerDelegate.stateObserver;

  @override
  OctopusState$Immutable get state => stateObserver.value;

  @override
  List<OctopusHistoryEntry> get history => stateObserver.history;

  @override
  bool get isIdle => !isProcessing;

  @override
  bool get isProcessing => config.routerDelegate.isProcessing;

  @override
  Future<void> get processingCompleted =>
      config.routerDelegate.processingCompleted;
}

base mixin _OctopusDelegateOwner on Octopus {
  @override
  abstract final OctopusStateObserver stateObserver;
}

base mixin _OctopusMethodsMixin on Octopus {
  @override
  Future<void> setState(
          OctopusState Function(OctopusState$Mutable state) change) =>
      config.routerDelegate.setNewRoutePath(change(state.mutate()));

  @override
  Future<void> navigate(String location) =>
      config.routerDelegate.setNewRoutePath(StateUtil.decodeLocation(location));

  @override
  Future<void> maybePop() => setState((state) {
        final children = state.children;
        if (children.length < 2) return state;
        return state;
      });

  @override
  Future<void> popAll() {
    // TODO: implement popAll
    throw UnimplementedError();
  }

  @override
  Future<void> popUntil(bool Function(OctopusNode node) predicate) {
    // TODO: implement popUntil
    throw UnimplementedError();
  }

  @override
  Future<void> push(OctopusRoute route) {
    // TODO: implement push
    throw UnimplementedError();
  }

  @override
  Future<void> pushAll(List<OctopusRoute> routes) {
    // TODO: implement pushAll
    throw UnimplementedError();
  }

  @override
  Future<void> pushAllNamed(
      List<({Map<String, String>? arguments, String name})> routes) {
    // TODO: implement pushAllNamed
    throw UnimplementedError();
  }

  @override
  Future<void> pushNamed(String name, {Map<String, String>? arguments}) {
    // TODO: implement pushNamed
    throw UnimplementedError();
  }

  @override
  Future<void> replace(OctopusRoute route) {
    // TODO: implement replace
    throw UnimplementedError();
  }

  @override
  Future<void> replaceNamed(String name, {Map<String, String>? arguments}) {
    // TODO: implement replaceNamed
    throw UnimplementedError();
  }
}

base mixin _OctopusTransactionMixin on Octopus, _OctopusMethodsMixin {
  Completer<void>? _txnCompleter;
  final Queue<(OctopusState Function(OctopusState$Mutable), int)> _txnQueue =
      Queue<(OctopusState Function(OctopusState$Mutable), int)>();

  @override
  Future<void> transaction(
    OctopusState Function(OctopusState$Mutable state) change, {
    int? priority,
  }) async {
    Completer<void> completer;
    if (_txnCompleter == null || _txnCompleter!.isCompleted) {
      completer = _txnCompleter = Completer<void>.sync();
      scheduleMicrotask(() {
        var mutableState = state.mutate();
        final list = _txnQueue.toList(growable: false)
          ..sort((a, b) => b.$2.compareTo(a.$2));
        _txnQueue.clear();
        for (final fn in list) {
          try {
            mutableState = switch (fn.$1(mutableState)) {
              OctopusState$Mutable state => state,
              OctopusState$Immutable state => state.mutate(),
            };
          } on Object {/* ignore */}
        }
        setState((_) => mutableState);
        if (completer.isCompleted) return;
        completer.complete();
      });
    } else {
      completer = _txnCompleter!;
    }
    priority ??= _txnQueue.fold<int>(0, (p, e) => math.min(p, e.$2)) - 1;
    _txnQueue.add((change, priority));
    return completer.future;
  }
}

/// {@template octopus_config}
/// Creates a [OctopusConfig] as a [RouterConfig].
/// {@endtemplate}
class OctopusConfig implements RouterConfig<OctopusState> {
  /// {@macro octopus_config}
  OctopusConfig({
    required this.routes,
    required this.routeInformationProvider,
    required this.routeInformationParser,
    required this.routerDelegate,
    required this.backButtonDispatcher,
  });

  /// The [OctopusRoute]s that are used to configure the [Router].
  final Map<String, OctopusRoute> routes;

  /// The [RouteInformationProvider] that is used to configure the [Router].
  @override
  final OctopusInformationProvider routeInformationProvider;

  /// The [RouteInformationParser] that is used to configure the [Router].
  @override
  final OctopusInformationParser routeInformationParser;

  /// The [RouterDelegate] that is used to configure the [Router].
  @override
  final OctopusDelegate routerDelegate;

  /// The [BackButtonDispatcher] that is used to configure the [Router].
  @override
  final BackButtonDispatcher backButtonDispatcher;
}
