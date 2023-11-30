import 'package:flutter/widgets.dart';
import 'package:octopus/octopus.dart';
import 'package:octopus/src/widget/no_animation_transition_delegate.dart';

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
  const OctopusNavigator({
    required Octopus controller,
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
  }) : _controller = controller;

  /// {@macro octopus_navigator}
  ///
  /// Create a nested navigator.
  static Widget nested({
    TransitionDelegate<Object?> transitionDelegate =
        const NoAnimationTransitionDelegate(),
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    String? restorationScopeId,
    Key? key,
  }) =>
      _OctopusNestedNavigatorBuilder(
        transitionDelegate: transitionDelegate,
        observers: observers,
        restorationScopeId: restorationScopeId,
        key: key,
      );

  /// Receives the [Octopus] instance from the elements tree.
  static Octopus? maybeOf(BuildContext context) {
    Octopus? controller;
    context.visitAncestorElements((element) {
      if (element is _OctopusNavigatorContext) {
        controller = element.controller;
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

  /// {@nodoc}
  final Octopus _controller;

  @override
  NavigatorState createState() => _OctopusNavigatorState();

  @override
  StatefulElement createElement() => _OctopusNavigatorContext(this);
}

class _OctopusNavigatorState extends NavigatorState {}

class _OctopusNavigatorContext extends StatefulElement {
  _OctopusNavigatorContext(OctopusNavigator super.widget)
      : controller = widget._controller;

  @override
  OctopusNavigator get widget => super.widget as OctopusNavigator;

  Octopus? controller;

  @override
  void mount(Element? parent, Object? newSlot) {
    // Mount the navigator.
    super.mount(parent, newSlot);
    controller = widget._controller;
  }

  @override
  void update(covariant OctopusNavigator newWidget) {
    // Unmount the navigator.
    super.update(newWidget);
    controller = newWidget._controller;
  }
}

class _OctopusNestedNavigatorBuilder extends StatefulWidget {
  const _OctopusNestedNavigatorBuilder({
    required this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    super.key,
  });

  final TransitionDelegate<Object?> transitionDelegate;
  final List<NavigatorObserver> observers;
  final String? restorationScopeId;

  @override
  State<_OctopusNestedNavigatorBuilder> createState() =>
      _OctopusNestedNavigatorBuilderState();
}

class _OctopusNestedNavigatorBuilderState
    extends State<_OctopusNestedNavigatorBuilder> {
  late Octopus _controller;
  OctopusNode? _node; // Current route node.
  List<Page<Object?>> _pages = const <Page<Object?>>[];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _controller = Octopus.of(context);
    _controller.config.routerDelegate.buildPagesFromNodes(
      context,
      _controller.state.children, // TODO(plugfox): from context
    );
    _controller.stateObserver.addListener(_handleStateChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _node = InheritedOctopusRoute.maybeOf(context, listen: true)?.node;
    _buildPages();
  }

  @override
  void dispose() {
    _controller.stateObserver.removeListener(_handleStateChange);
    super.dispose();
  }
  /* #endregion */

  void _handleStateChange() {
    _node ??= InheritedOctopusRoute.maybeOf(context, listen: false)?.node;
    if (_node == null) return;
    // TODO(plugfox): check if the node is in the tree
  }

  void _buildPages() {
    final children = _node?.children;
    if (children == null || children.isEmpty) {
      _pages = const <Page<Object?>>[];
      return;
    }

    _controller.config.routerDelegate.buildPagesFromNodes(
      context,
      _controller.state.children, // TODO(plugfox): from context
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox.shrink();
    return OctopusNavigator(
      controller: _controller,
      restorationScopeId: widget.restorationScopeId,
      reportsRouteUpdateToEngine: false,
      observers: <NavigatorObserver>[
        ...widget.observers,
      ],
      transitionDelegate: widget.transitionDelegate,
      pages: _pages,
    );
  }
}
