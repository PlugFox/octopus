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
        bucket: bucket,
        transitionDelegate: transitionDelegate,
        observers: observers,
        restorationScopeId: restorationScopeId,
        navigatorKey: switch (key) {
          GlobalKey key => key,
          _ => null,
        },
        key: switch (key) {
          LocalKey key => key,
          GlobalKey key => ValueKey<String>('OctopusNavigator#${key.hashCode}'),
          _ => null,
        },
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
  const _OctopusNestedNavigatorBuilder({
    required this.defaultRoute,
    this.bucket,
    this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    this.navigatorKey,
    super.key,
  });

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
    extends State<_OctopusNestedNavigatorBuilder> {
  // TODO(plugfox): back button dispatcher
  late Octopus _router;
  OctopusNode? _parentNode; // Current route node.
  List<Page<Object?>> _pages = const <Page<Object?>>[];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _router = Octopus.of(context);
    _router.stateObserver.addListener(_handleStateChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parentNode = InheritedOctopusRoute.maybeOf(context, listen: true)?.node;
    _buildPages();
  }

  @override
  void dispose() {
    _router.stateObserver.removeListener(_handleStateChange);
    super.dispose();
  }
  /* #endregion */

  void _handleStateChange() {
    if (!mounted) return;
    _parentNode ??= InheritedOctopusRoute.maybeOf(context, listen: false)?.node;
    setState(_buildPages);
  }

  void _buildPages() {
    _pages = _router.config.routerDelegate.buildPagesFromNodes(
      context,
      _parentNode?.children ?? const <OctopusNode>[],
      widget.defaultRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox.shrink();
    return OctopusNavigator(
      key: widget.navigatorKey,
      router: _router,
      restorationScopeId: widget.restorationScopeId,
      reportsRouteUpdateToEngine: false,
      observers: <NavigatorObserver>[
        ...widget.observers,
      ],
      transitionDelegate:
          widget.transitionDelegate ?? const NoAnimationTransitionDelegate(),
      pages: _pages,
    );
  }
}
