import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/config.dart';
import 'package:octopus/src/controller/controller.dart';
import 'package:octopus/src/controller/guard.dart';
import 'package:octopus/src/controller/information_parser.dart';
import 'package:octopus/src/controller/information_provider.dart';
import 'package:octopus/src/controller/navigator/delegate.dart';
import 'package:octopus/src/controller/navigator/observer.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/controller/singleton.dart';
import 'package:octopus/src/controller/typedefs.dart';
import 'package:octopus/src/state/name_regexp.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/util/state_util.dart';

/// {@nodoc}
@internal
final class Octopus$NavigatorImpl implements Octopus {
  /// {@nodoc}
  factory Octopus$NavigatorImpl({
    required Iterable<OctopusRoute> routes,
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
    final list = List<OctopusRoute>.of(routes, growable: false);
    assert(list.isNotEmpty, 'Routes list should contain at least one route');
    defaultRoute ??= list.firstOrNull;
    if (defaultRoute == null) {
      final error = StateError('Routes list should contain at least one route');
      onError?.call(error, StackTrace.current);
      throw error;
    }
    assert(
      list.every((e) => e.name.length > 1 && !e.name.startsWith('/')),
      'Route name should not start with a "/" '
      'and should be at least 2 characters long',
    );
    assert(
      list.every((e) => e.name.contains($nameRegExp)),
      'Route name should contain only latin letters, numbers, and hyphens',
    );
    assert(
      list.map<String>((e) => e.name).toSet().length == list.length,
      'Routes list should not contain duplicate names',
    );
    final routeInformationProvider = OctopusInformationProvider.platform();
    final backButtonDispatcher = RootBackButtonDispatcher();
    final routeInformationParser = OctopusInformationParser(codec: codec);
    final routesTable = Map<String, OctopusRoute>.unmodifiable(
      <String, OctopusRoute>{
        for (final route in list) route.name: route,
      },
    );
    final observer = OctopusStateObserver$NavigatorImpl(
      initialState?.freeze() ??
          OctopusState$Immutable(
            children: <OctopusNode>[defaultRoute.node()],
            arguments: const <String, String>{},
            intention: OctopusStateIntention.neglect,
          ),
      history,
    );
    final routerDelegate = OctopusDelegate$NavigatorImpl(
      observer: observer,
      routes: routesTable,
      defaultRoute: defaultRoute,
      guards: guards,
      restorationScopeId: restorationScopeId,
      observers: observers,
      transitionDelegate: transitionDelegate,
      notFound: notFound,
      onError: onError,
    );
    final controller = Octopus$NavigatorImpl._(
      routes: routesTable,
      routeInformationProvider: routeInformationProvider,
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher,
      observer: observer,
    );
    routerDelegate.$octopus = WeakReference<Octopus>(controller);
    return controller;
  }

  Octopus$NavigatorImpl._({
    required Map<String, OctopusRoute> routes,
    required OctopusDelegate$NavigatorImpl routerDelegate,
    required OctopusInformationProvider routeInformationProvider,
    required OctopusInformationParser routeInformationParser,
    required BackButtonDispatcher backButtonDispatcher,
    required OctopusStateObserver observer,
  })  : config = OctopusConfig(
          routes: routes,
          routeInformationProvider: routeInformationProvider,
          routeInformationParser: routeInformationParser,
          routerDelegate: routerDelegate,
          backButtonDispatcher: backButtonDispatcher,
          observer: observer,
        ),
        _routerDelegate = routerDelegate {
    $octopusSingletonInstance = this;
  }

  @override
  final OctopusConfig config;

  final OctopusDelegate$NavigatorImpl _routerDelegate;

  @override
  OctopusStateObserver get stateObserver => observer;

  @override
  OctopusStateObserver get observer => config.observer;

  @override
  OctopusState$Immutable get state => stateObserver.value;

  @override
  List<OctopusHistoryEntry> get history => stateObserver.history;

  @override
  bool get isIdle => !isProcessing;

  @override
  bool get isProcessing => _routerDelegate.isProcessing;

  @override
  Future<void> get processingCompleted => _routerDelegate.processingCompleted;

  @override
  OctopusRoute? getRouteByName(String name) => config.routes[name];

  @override
  Future<void> setState(
          OctopusState Function(OctopusState$Mutable state) change) =>
      _routerDelegate.setNewRoutePath(
          change(state.mutate()..intention = OctopusStateIntention.auto));

  @override
  Future<void> navigate(String location) =>
      _routerDelegate.setNewRoutePath(StateUtil.decodeLocation(location));

  @override
  Future<OctopusNode?> pop() {
    OctopusNode? result;
    return setState((state) {
      if (state.children.length < 2) {
        SystemNavigator.pop().ignore();
        return state;
      }
      result = state.removeLast();
      return state;
    }).then((_) => result);
  }

  @override
  Future<OctopusNode?> maybePop() {
    OctopusNode? result;
    return setState((state) {
      if (state.children.length < 2) return state;
      result = state.removeLast();
      return state;
    }).then((_) => result);
  }

  @override
  Future<void> popAll() => setState((state) {
        final first = state.children.firstOrNull;
        if (first == null) return state;
        return OctopusState.single(first, arguments: state.arguments);
      });

  @override
  Future<List<OctopusNode>> popUntil(
      bool Function(OctopusNode$Mutable node) predicate) {
    final result = <OctopusNode>[];
    return setState((state) {
      result.addAll(state.removeUntil(predicate));
      return state;
    }).then((_) => result);
  }

  @override
  Future<void> push(OctopusRoute route, {Map<String, String>? arguments}) =>
      setState((state) => state..add(route.node(arguments: arguments)));

  @override
  Future<void> pushNamed(String name, {Map<String, String>? arguments}) {
    final route = getRouteByName(name);
    if (route == null) {
      assert(false, 'Route with name "$name" not found');
      return Future<void>.value();
    } else {
      return push(route, arguments: arguments);
    }
  }

  @override
  Future<void> pushAll(
          List<({OctopusRoute route, Map<String, String>? arguments})>
              routes) =>
      setState((state) => state
        ..addAll(
            [for (final e in routes) e.route.node(arguments: e.arguments)]));

  @override
  Future<void> pushAllNamed(
      List<({String name, Map<String, String>? arguments})> routes) {
    final nodes = <OctopusNode>[];
    final table = config.routes;
    for (final e in routes) {
      final route = table[e.name];
      if (route == null) {
        assert(false, 'Route with name "${e.name}" not found');
      } else {
        nodes.add(route.node(arguments: e.arguments));
      }
    }
    if (nodes.isEmpty) return Future<void>.value();
    return setState((state) => state..addAll(nodes));
  }

  @override
  Future<OctopusNode> upsertLast(
    OctopusRoute route, {
    Map<String, String>? arguments,
  }) {
    late OctopusNode result;
    return setState((state) {
      result = state.upsertLast(route.node(arguments: arguments));
      return state;
    }).then((_) => result);
  }

  @override
  Future<OctopusNode> upsertLastNamed(
    String name, {
    Map<String, String>? arguments,
  }) {
    final route = getRouteByName(name);
    if (route == null) {
      throw StateError('Route with name "$name" not found');
    } else {
      return upsertLast(route, arguments: arguments);
    }
  }

  @override
  Future<void> replaceAll(
    OctopusNode Function(OctopusNode$Mutable) fn, {
    bool recursive = true,
  }) =>
      setState((state) => state..replaceAll(fn, recursive: recursive));

  @override
  Future<void> setArguments(void Function(Map<String, String> args) change) =>
      setState((state) {
        change(state.arguments);
        return state;
      });

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
      Future<void>.delayed(Duration.zero, () {
        var mutableState = state.mutate()
          ..intention = OctopusStateIntention.auto;
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

  @override
  Future<T?> showDialog<T>(
    WidgetBuilder builder, {
    Map<String, String>? arguments,
  }) =>
      _routerDelegate.showDialog<T>(builder, arguments: arguments);
}
