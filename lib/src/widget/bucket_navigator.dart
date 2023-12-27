import 'dart:async';

import 'package:flutter/material.dart';
import 'package:octopus/src/controller/controller.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/widget/build_context_extension.dart';
import 'package:octopus/src/widget/navigator.dart';
import 'package:octopus/src/widget/no_animation.dart';
import 'package:octopus/src/widget/route_context.dart';

/// {@template bucket_navigator}
///
/// Nested navigation widget that manages a stack of pages.
///
/// The [bucket] unique identifier is used to identify the navigator
/// within the all application.
/// The [handlesBackButton] parameter is used to decide whether this navigator
/// should handle back button presses.
/// The [transitionDelegate] parameter is used to customize the transition
/// animation.
/// The [observers] parameter is used to observe the navigation events.
/// The [restorationScopeId] parameter is used to restore the navigation
/// state.
/// {@endtemplate}
class BucketNavigator extends StatefulWidget {
  /// {@macro bucket_navigator}
  const BucketNavigator({
    required this.bucket,
    this.handlesBackButton,
    this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    super.key,
  });

  /// The unique identifier of the navigator.
  final String bucket;

  /// The [handlesBackButton] parameter is used to decide whether this navigator
  /// should handle back button presses.
  /// Usefull when you want to handle back button only when the current screen
  /// is in focus now.
  /// By default, the value is `true` if the navigator has more than one page.
  final bool Function()? handlesBackButton;

  /// The delegate that decides how the route transition animation should
  /// look like.
  final TransitionDelegate<Object?>? transitionDelegate;

  /// The list of observers for this navigator.
  final List<NavigatorObserver> observers;

  /// The restoration scope id to use for this navigator.
  final String? restorationScopeId;

  @override
  State<BucketNavigator> createState() => _BucketNavigatorState();
}

/// State for widget BucketNavigator.
class _BucketNavigatorState extends State<BucketNavigator>
    with _BackButtonBucketNavigatorStateMixin {
  /// Octopus router.
  late final Octopus _router;

  /// State observer.
  late final OctopusStateObserver _observer;

  /// Current bucket node.
  OctopusNode$Immutable? _node;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _router = context.octopus;
    _observer = _router.observer;
    _observer.addListener(_handleStateChange);
    _handleStateChange();
  }

  @override
  void didUpdateWidget(covariant BucketNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bucket != oldWidget.bucket) {
      _observer
        ..removeListener(_handleStateChange)
        ..addListener(_handleStateChange);
    }
  }

  @override
  void dispose() {
    _observer.removeListener(_handleStateChange);
    super.dispose();
  }
  /* #endregion */

  /// Callback for router state changes.
  void _handleStateChange() {
    if (!mounted) return;
    final newNode = _observer.value.findByName(widget.bucket);
    if (newNode == _node) return;
    setState(() => _node = newNode);
  }

  @override
  Widget build(BuildContext context) {
    final node = _node;
    if (node == null || !node.hasChildren) return const SizedBox.shrink();
    final pages =
        _router.config.routerDelegate.buildPages(context, node.children);
    if (pages.isEmpty) return const SizedBox.shrink();
    return InheritedOctopusRoute(
      node: node,
      child: OctopusNavigator(
        router: _router,
        restorationScopeId: widget.restorationScopeId,
        reportsRouteUpdateToEngine: false,
        observers: <NavigatorObserver>[
          ...widget.observers,
        ],
        transitionDelegate: widget.transitionDelegate ??
            (NoAnimationScope.of(context)
                ? const NoAnimationTransitionDelegate<Object?>()
                : const DefaultTransitionDelegate<Object?>()),
        pages: pages,
        onPopPage: _onPopPage,
      ),
    );
  }

  bool _onPopPage(Route<Object?> route, Object? result) {
    if (!route.didPop(result)) return false;
    final node = _node;
    if (node == null) return false;
    if (node.children.length < 2) return false;
    _router.setState(
      (state) {
        final node = state.findByName(widget.bucket);
        if (node == null || node.children.length < 2)
          return state..intention = OctopusStateIntention.cancel;
        node.removeLast();
        return state;
      },
    );
    return true;
  }

  @override
  Future<bool> _onBackButtonPressed() {
    if (!mounted) return Future<bool>.value(false);
    final handlesBackButton = widget.handlesBackButton;
    if (handlesBackButton != null && !handlesBackButton())
      return Future<bool>.value(false);
    final node = _node;
    if (node == null) return Future<bool>.value(false);
    if (node.children.length < 2) return Future<bool>.value(false);
    final completer = Completer<bool>();
    // ignore: avoid_positional_boolean_parameters
    void complete(bool value) {
      if (completer.isCompleted) return;
      completer.complete(value);
    }

    _router.setState(
      (state) {
        final node = state.findByName(widget.bucket);
        if (node == null || node.children.length < 2) {
          complete(false);
          return state..intention = OctopusStateIntention.cancel;
        }
        node.removeLast();
        return state;
      },
    ).whenComplete(() => complete(true));
    return completer.future;
  }
}

/// {@nodoc}
mixin _BackButtonBucketNavigatorStateMixin on State<BucketNavigator> {
  BackButtonDispatcher? dispatcher;

  Future<bool> _onBackButtonPressed();

  @override
  void initState() {
    dispatcher?.removeCallback(_onBackButtonPressed);
    final rootBackDispatcher = context.octopus.config.backButtonDispatcher;
    dispatcher = rootBackDispatcher.createChildBackButtonDispatcher()
      ..addCallback(_onBackButtonPressed)
      ..takePriority();
    super.initState();
  }

  @override
  void dispose() {
    dispatcher?.removeCallback(_onBackButtonPressed);
    super.dispose();
  }
}
