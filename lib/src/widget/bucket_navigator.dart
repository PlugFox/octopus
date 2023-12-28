import 'dart:async';

import 'package:flutter/foundation.dart';
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
/// The [shouldHandleBackButton] parameter is used to decide whether this navigator
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
    this.shouldHandleBackButton,
    this.onBackButtonPressed,
    this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    super.key,
  });

  /// The unique identifier of the navigator.
  final String bucket;

  /// The [shouldHandleBackButton] parameter is used to decide
  /// whether this navigator should handle back button presses.
  /// Usefull when you want to handle back button only when the current screen
  /// is in focus now.
  /// By default, the value is `true` if the navigator has more than one page.
  final bool Function(BuildContext context)? shouldHandleBackButton;

  /// Override the default back button behavior logic.
  final Future<bool> Function(BuildContext context, NavigatorState navigator)?
      onBackButtonPressed;

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

  /// Navigator observer
  final NavigatorObserver _navigatorObserver = NavigatorObserver();

  /// State observer.
  late final OctopusStateObserver _stateObserver;

  /// Current bucket node.
  OctopusNode$Immutable? _node;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _router = context.octopus;
    _stateObserver = _router.observer;
    _stateObserver.addListener(_handleStateChange);
    _handleStateChange();
  }

  @override
  void didUpdateWidget(covariant BucketNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bucket != oldWidget.bucket) {
      _stateObserver
        ..removeListener(_handleStateChange)
        ..addListener(_handleStateChange);
    }
  }

  @override
  void dispose() {
    _stateObserver.removeListener(_handleStateChange);
    super.dispose();
  }
  /* #endregion */

  /// Callback for router state changes.
  void _handleStateChange() {
    if (!mounted) return;
    final newNode = _stateObserver.value.findByName(widget.bucket);
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
          _navigatorObserver,
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
    // Do not handle back button if the navigator is not in focus.
    if (!mounted) return SynchronousFuture<bool>(false);

    // Check if the navigator should handle back button.
    // e.g. if the navigator is not in focus.
    final handlesBackButton = widget.shouldHandleBackButton;
    if (handlesBackButton != null && !handlesBackButton(context))
      return SynchronousFuture<bool>(false);

    // Get the navigator from the observer.
    final nav = _navigatorObserver.navigator;
    assert(nav != null, 'Navigator is not attached to the OctopusDelegate');
    if (nav == null) return SynchronousFuture<bool>(false);

    // Check if the navigator has custom back button behavior.
    final onBackButtonPressed = widget.onBackButtonPressed;
    if (onBackButtonPressed != null) return onBackButtonPressed(context, nav);

    // Handle back button by default with the current navigator.
    return nav.maybePop();
  }
}

/// {@nodoc}
mixin _BackButtonBucketNavigatorStateMixin on State<BucketNavigator> {
  Future<bool> _onBackButtonPressed();

  late final Octopus _bbRouter;
  late final BackButtonDispatcher _bbDispatcher;
  bool _bbHasPriority = false;

  @override
  void initState() {
    super.initState();
    _bbRouter = context.octopus;
    _bbDispatcher =
        _bbRouter.config.backButtonDispatcher.createChildBackButtonDispatcher();
    _bbRouter.observer.addListener(_checkPriority);
    _checkPriority();
  }

  void _checkPriority() {
    final bucket = widget.bucket;
    var children = _bbRouter.observer.value.children;
    var priority = false;
    while (true) {
      if (children.isEmpty) break;
      if (children.any((node) => node.name == bucket)) {
        priority = true;
        break;
      }
      children = children.last.children;
    }

    if (priority == _bbHasPriority) return;
    _bbHasPriority = priority;
    if (priority) {
      _bbDispatcher
        ..addCallback(_onBackButtonPressed)
        ..takePriority();
    } else {
      _bbDispatcher.removeCallback(_onBackButtonPressed);
    }
  }

  @override
  void dispose() {
    _bbDispatcher.removeCallback(_onBackButtonPressed);
    _bbRouter.observer.removeListener(_checkPriority);
    super.dispose();
  }
}
