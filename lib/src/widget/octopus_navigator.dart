import 'package:flutter/widgets.dart';
import 'package:octopus/src/controller/octopus.dart';

/// {@nodoc}
class OctopusNavigator extends Navigator {
  /// {@nodoc}
  const OctopusNavigator({
    required this.controller,
    super.pages = const <Page<Object?>>[],
    super.onPopPage,
    super.onUnknownRoute,
    super.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    super.reportsRouteUpdateToEngine = false,
    super.clipBehavior = Clip.hardEdge,
    super.observers = const <NavigatorObserver>[],
    super.requestFocus = true,
    super.restorationScopeId,
    super.routeTraversalEdgeBehavior = kDefaultRouteTraversalEdgeBehavior,
    super.key,
  });

  /// {@nodoc}
  final Octopus controller;

  @override
  StatefulElement createElement() => _OctopusNavigatorContext(this);
}

class _OctopusNavigatorContext extends StatefulElement {
  _OctopusNavigatorContext(OctopusNavigator super.widget);

  @override
  OctopusNavigator get widget => super.widget as OctopusNavigator;

  @override
  void mount(Element? parent, Object? newSlot) {
    // Mount the navigator.
    super.mount(parent, newSlot);
  }

  @override
  void update(covariant OctopusNavigator newWidget) {
    // Unmount the navigator.
    super.update(newWidget);
  }
}
