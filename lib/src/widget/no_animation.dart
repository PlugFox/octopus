import 'package:flutter/widgets.dart';

/// {@template no_animation_scope}
/// NoAnimationInherited widget.
/// Disables animations for all [Navigator]s below it.
///
/// Works without subscription!
/// Does not change already created [Navigator]s and [Route]s!
/// {@endtemplate}
class NoAnimationScope extends InheritedWidget {
  /// {@macro no_animation_scope}
  const NoAnimationScope({
    required super.child,
    this.noAnimation = true,
    super.key,
  });

  /// Disables animations for all [Navigator]s below it.
  static bool of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<NoAnimationScope>()?.noAnimation ==
      true;

  /// Disables animations for all [Navigator]s below it.
  final bool noAnimation;

  @override
  bool updateShouldNotify(covariant NoAnimationScope oldWidget) => false;
}

/// {@template no_animation_transition_delegate}
/// A [TransitionDelegate] for [Navigator] that does not animate when pushing.
/// {@endtemplate}
@immutable
class NoAnimationTransitionDelegate<T> extends TransitionDelegate<T> {
  /// {@macro no_animation_transition_delegate}
  const NoAnimationTransitionDelegate();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}

/// {@template no_animation_page}
/// Page for [OctopusRoute.defaultPageBuilder] that does not animate
/// when pushed or popped.
/// {@endtemplate}
@immutable
class NoAnimationPage<T> extends Page<T> {
  /// {@macro no_animation_page}
  const NoAnimationPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// Whether the route should remain in memory when it is inactive.
  final bool maintainState;

  /// Whether this page route is a full-screen dialog.
  final bool fullscreenDialog;

  /// Whether the route transition will prefer
  /// to animate a snapshot of the entering/exiting routes.
  final bool allowSnapshotting;

  @override
  Route<T> createRoute(BuildContext context) =>
      _NoAnimationPageRoute<T>(page: this);
}

class _NoAnimationPageRoute<T> extends PageRoute<T> {
  _NoAnimationPageRoute({
    required NoAnimationPage<T> page,
    super.allowSnapshotting,
  }) : super(settings: page);

  NoAnimationPage<T> get _page => settings as NoAnimationPage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is PageRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is PageRoute;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Duration get transitionDuration => Duration.zero;
}
