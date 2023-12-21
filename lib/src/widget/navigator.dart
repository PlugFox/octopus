import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/octopus.dart';
import 'package:octopus/src/state/name_regexp.dart';
import 'package:octopus/src/util/state_util.dart';

/// {@template octopus_navigator}
/// Octopus navigator widget.
/// {@endtemplate}
class OctopusNavigator extends Navigator {
  /// {@macro octopus_navigator}
  ///
  /// Do not use this constructor directly,
  /// use [OctopusNavigator.nested] instead.
  ///
  /// You can use the [OctopusNavigator.nested] constructor to create a nested
  /// navigator.
  @internal
  const OctopusNavigator({
    required Octopus router,
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
  }) : _router = router;

  /// {@macro octopus_navigator}
  ///
  /// Create a nested navigator.
  ///
  /// The [defaultRoute] parameter is used to specify the default route
  /// if the current nodes are empty as a fallback option.
  /// The [bucket] parameter is used to separate the nodes of the nested
  /// navigator from the other navigators at the same level.
  /// The [transitionDelegate] parameter is used to customize the transition
  /// animation.
  /// The [observers] parameter is used to observe the navigation events.
  /// The [restorationScopeId] parameter is used to restore the navigation
  /// state.
  /// The [key] parameter is used to identify the navigator.
  static Widget nested({
    required OctopusRoute defaultRoute,
    String? bucket,
    TransitionDelegate<Object?>? transitionDelegate,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    String? restorationScopeId,
    Key? key,
  }) =>
      _OctopusNestedNavigatorBuilder(
        defaultRoute: defaultRoute,
        bucket: bucket == null || bucket.isEmpty ? null : bucket,
        transitionDelegate: transitionDelegate,
        observers: observers,
        restorationScopeId: restorationScopeId,
        navigatorKey: switch (key) {
          GlobalKey key => key,
          _ => null,
        },
        key: ValueKey<String>(
          'OctopusNavigator'
          '#'
          '${key.hashCode}'
          '${bucket == null ? '' : '/$bucket'}',
        ),
      );

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus? maybeOf(BuildContext context) {
    Octopus? controller;
    context.visitAncestorElements((element) {
      if (element is _OctopusNavigatorContext) {
        controller = element.router;
        if (controller != null) return false;
      }
      return true;
    });
    return controller;
  }

  static Never _notFound() => throw ArgumentError(
        'Out of scope, not found a OctopusNavigator widget',
        'out_of_scope',
      );

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus of(BuildContext context) => maybeOf(context) ?? _notFound();

  /// Push a new route.
  static void push(BuildContext context, OctopusRoute route,
      {Map<String, String>? arguments, bool useRootNavigator = false}) {
    if (!useRootNavigator) {
      var pushed = false;
      context.visitAncestorElements((element) {
        if (element
            case StatefulElement(
              state: _ImperativeNestedNavigatorStateMixin state,
            )) {
          state.pushRoute(route, arguments);
          pushed = true;
          return false;
        }
        return true;
      });
      if (pushed) return;
    }
    // Fallback or useRootNavigator is true.
    Octopus.maybeOf(context)?.setState(
      (state) => state
        ..add(route.node(arguments: arguments ?? const <String, String>{})),
    );
  }

  /// Try to pop the last route.
  static void maybePop(BuildContext context) => Navigator.maybePop(context);

  /// Pop the last route.
  static void pop(BuildContext context) => Navigator.pop(context);

  /// {@nodoc}
  final Octopus _router;

  @override
  NavigatorState createState() => _OctopusNavigatorState();

  @override
  StatefulElement createElement() => _OctopusNavigatorContext(this);
}

class _OctopusNavigatorState extends NavigatorState {}

class _OctopusNavigatorContext extends StatefulElement {
  _OctopusNavigatorContext(OctopusNavigator super.widget)
      : router = widget._router;

  @override
  OctopusNavigator get widget => super.widget as OctopusNavigator;

  Octopus? router;

  @override
  void mount(Element? parent, Object? newSlot) {
    // Mount the navigator.
    super.mount(parent, newSlot);
    router = widget._router;
  }

  @override
  void update(covariant OctopusNavigator newWidget) {
    // Unmount the navigator.
    super.update(newWidget);
    router = newWidget._router;
  }
}

class _OctopusNestedNavigatorBuilder extends StatefulWidget {
  _OctopusNestedNavigatorBuilder({
    required this.defaultRoute,
    this.bucket,
    this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    this.navigatorKey,
    super.key,
  }) : assert(
          bucket == null || bucket.contains($nameRegExp),
          'Bucket name must be a valid name',
        );

  final OctopusRoute defaultRoute;
  final String? bucket;
  final TransitionDelegate<Object?>? transitionDelegate;
  final List<NavigatorObserver> observers;
  final String? restorationScopeId;
  final Key? navigatorKey;

  @override
  State<_OctopusNestedNavigatorBuilder> createState() =>
      _OctopusNestedNavigatorBuilderState();
}

class _OctopusNestedNavigatorBuilderState
    extends State<_OctopusNestedNavigatorBuilder>
    with
        _ImperativeNestedNavigatorStateMixin<_OctopusNestedNavigatorBuilder>,
        _BackButtonNestedNavigatorStateMixin<_OctopusNestedNavigatorBuilder> {
  /// Controller.
  late Octopus _router;

  /// Current nodes.
  List<OctopusNode> _nodes = <OctopusNode>[];

  /// Current pages.
  List<Page<Object?>> _pages = const <Page<Object?>>[];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _router = Octopus.of(context);
    _nodes = _getNodesFromContext();
    _pages = _buildPages();
    _router.stateObserver.addListener(_handleStateChange);
    // If the nodes are empty, we need to wait for the processing to complete.
    // And add our bucket and fallback route to the router.
    if (_nodes.isEmpty) _router.processingCompleted.whenComplete(_checkBucket);
  }

  @override
  void dispose() {
    _router.stateObserver.removeListener(_handleStateChange);
    super.dispose();
  }
  /* #endregion */

  bool _awaitingToCheckBucket = false;

  /// Check the bucket and add it if necessary to the router.
  void _checkBucket() {
    if (!mounted) return;
    if (_awaitingToCheckBucket) return; // Already waiting - do nothing.
    if (_router.isProcessing) {
      // If the router is processing, we need to wait for the processing to
      // complete and then check the bucket.
      _awaitingToCheckBucket = true;
      _router.processingCompleted.whenComplete(() {
        _awaitingToCheckBucket = false;
        _checkBucket();
      }).ignore();
      return; // Wait for processing to complete.
    }
    // Get parents from context without bucket.
    final parents = InheritedOctopusRoute.findAncestorNodes(context);
    var parent = StateUtil.extractNodeFromStateByPath(_router.state, parents);
    if (parent == null) return;
    if (widget.bucket case String bucket) {
      final bucketNode =
          parent.children.firstWhereOrNull((n) => n.name == bucket);
      if (bucketNode == null) {
        // Add the bucket node.
        _router.transaction(
          (state) {
            if (state.intention == OctopusStateIntention.auto) {
              state.intention = OctopusStateIntention.replace;
            }
            final parent = StateUtil.extractNodeFromStateByPath(
              state,
              parents,
            );
            if (parent == null) return state;
            parent.children.add(
              OctopusNode.immutable(
                bucket,
                children: <OctopusNode>[
                  widget.defaultRoute.node(),
                ],
              ),
            );
            return state;
          },
        );
        return;
      } else {
        parent = bucketNode;
      }
    }
    if (parent.children.isEmpty) {
      // Add default route.
      _router.transaction(
        (state) {
          if (state.intention == OctopusStateIntention.auto) {
            state.intention = OctopusStateIntention.replace;
          }
          final parent = StateUtil.extractNodeFromStateByPath(
            state,
            parents,
          );
          if (parent == null) return state;
          parent.children.add(widget.defaultRoute.node());
          return state;
        },
      );
      return;
    }
  }

  /// Callback for router state changes.
  void _handleStateChange() {
    if (!mounted) return;
    final newNodes = _getNodesFromContext();
    if (newNodes.isEmpty) {
      // If nodes are empty we should check the bucket and add it if necessary.
      _checkBucket();
    }
    if (listEquals(_nodes, newNodes)) return;
    setState(() {
      _nodes = newNodes;
      _pages = _buildPages();
    });
  }

  /// Cache for parents.
  OctopusNode? _$parentCache;

  /// Get current parent node from context (including bucket)
  OctopusNode? _getParentFromContext() {
    if (_$parentCache case OctopusNode parent) return parent;
    scheduleMicrotask(() => _$parentCache = null);
    if (!mounted) return _$parentCache = null;
    final parent = StateUtil.extractNodeFromStateByPath(
        _router.state, InheritedOctopusRoute.findAncestorNodes(context));
    final bucket = widget.bucket;
    if (bucket == null) return _$parentCache = parent;
    final bucketNode =
        parent?.children.firstWhereOrNull((n) => n.name == bucket);
    if (bucketNode == null) return _$parentCache = null;
    return _$parentCache = bucketNode;
  }

  /// Cache for nodes.
  List<OctopusNode>? _$nodeCache;

  /// Get all nodes for current context.
  List<OctopusNode> _getNodesFromContext() {
    if (_$nodeCache case List<OctopusNode> nodes) return nodes;
    scheduleMicrotask(() => _$nodeCache = null);
    if (!mounted) return _$nodeCache = const <OctopusNode>[];
    final parent = _getParentFromContext();
    if (parent == null) return _$nodeCache = const <OctopusNode>[];
    return _$nodeCache = parent.children;
  }

  List<Page<Object?>> _buildPages() =>
      _router.config.routerDelegate.buildPagesFromNodes(
        context,
        _getNodesFromContext(),
        widget.defaultRoute,
      );

  @override
  void pushRoute(OctopusRoute route, [Map<String, String>? arguments]) {
    if (!mounted) return;
    _router.transaction(
      (state) {
        // Get parents list, without bucket.
        final parents = InheritedOctopusRoute.findAncestorNodes(context);
        var parent = StateUtil.extractNodeFromStateByPath(state, parents);
        if (parent == null) return state; // Not found parent.
        final bucket = widget.bucket;
        if (bucket != null) {
          // Find or create the bucket node.
          parent = parent.children.firstWhereOrNull((n) => n.name == bucket);
          parent ??= OctopusNode.mutable(
            bucket,
            children: <OctopusNode>[],
          );
        }
        if (parent.children.isEmpty) {
          // Add the default route as a current route before the new route.
          parent.children.add(widget.defaultRoute.node());
        }
        // Add the new route.
        parent.children.add(
          route.node(
            arguments: arguments ?? const <String, String>{},
          ),
        );
        return state;
      },
    );
  }

  bool _onPopPage(Route<Object?> route, Object? result) {
    if (!route.didPop(result)) return false;
    final parent = _getParentFromContext();
    if (parent == null) return false;
    if (parent.children.length < 2) return false;
    _router.transaction(
      (state) {
        // Get parents list, without bucket.
        final parents = InheritedOctopusRoute.findAncestorNodes(context);
        var parent = StateUtil.extractNodeFromStateByPath(state, parents);
        if (widget.bucket case String bucket)
          parent = parent?.children
              .firstWhereOrNull((n) => n.name == bucket); // Find bucket node.
        if (parent == null) return state; // Not found parent.
        if (parent.children.isEmpty) return state;
        parent.children.removeLast();
        return state;
      },
    );
    return true;
  }

  @override
  Future<bool> onBackButtonPressed() {
    if (!mounted) return Future<bool>.value(false);
    final parent = _getParentFromContext();
    if (parent == null) return Future<bool>.value(false);
    if (parent.children.length < 2) return Future<bool>.value(false);
    _router.transaction(
      (state) {
        // Get parents list, without bucket.
        final parents = InheritedOctopusRoute.findAncestorNodes(context);
        var parent = StateUtil.extractNodeFromStateByPath(state, parents);
        if (widget.bucket case String bucket)
          parent = parent?.children
              .firstWhereOrNull((n) => n.name == bucket); // Find bucket node.
        if (parent == null) return state; // Not found parent.
        if (parent.children.isEmpty) return state;
        parent.children.removeLast();
        return state;
      },
    );
    return Future<bool>.value(true);
  }

  Widget buildNavigator(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox.shrink();
    return OctopusNavigator(
      key: widget.navigatorKey,
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
      pages: _pages,
      onPopPage: _onPopPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bucket = widget.bucket;
    if (bucket == null) return buildNavigator(context);
    return InheritedOctopusRoute(
      node: OctopusNode.immutable(
        bucket,
        children: _nodes,
      ),
      child: buildNavigator(context),
    );
  }
}

/// {@nodoc}
mixin _ImperativeNestedNavigatorStateMixin<T extends StatefulWidget>
    on State<T> {
  /// Push a new route.
  void pushRoute(OctopusRoute route, [Map<String, String>? arguments]);
}

/// {@nodoc}
mixin _BackButtonNestedNavigatorStateMixin<T extends StatefulWidget>
    on State<T> {
  BackButtonDispatcher? dispatcher;

  Future<bool> onBackButtonPressed();

  @override
  void initState() {
    // TODO(plugfox): check priority for nested navigators
    dispatcher?.removeCallback(onBackButtonPressed);
    final rootBackDispatcher = Octopus.of(context).config.backButtonDispatcher;
    dispatcher = rootBackDispatcher.createChildBackButtonDispatcher()
      ..addCallback(onBackButtonPressed)
      ..takePriority();
    super.initState();
  }

  @override
  void dispose() {
    dispatcher?.removeCallback(onBackButtonPressed);
    super.dispose();
  }
}
