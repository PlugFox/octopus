import 'package:flutter/widgets.dart';
import 'package:octopus/src/state/state.dart';

/// {@template inherited_octopus_route}
/// InheritedOctopusRoute widget.
/// {@endtemplate}
class InheritedOctopusRoute extends InheritedWidget {
  /// {@macro inherited_octopus_route}
  const InheritedOctopusRoute({
    required this.node,
    required super.child,
    super.key,
  });

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `InheritedOctopusRoute.maybeOf(context)`.
  static InheritedOctopusRoute? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<InheritedOctopusRoute>()
          : context.getInheritedWidgetOfExactType<InheritedOctopusRoute>();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a InheritedOctopusRoute of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `InheritedOctopusRoute.of(context)`
  static InheritedOctopusRoute of(
    BuildContext context, {
    bool listen = true,
  }) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  /// Get all parents node for current context.
  /// First element is the current route node.
  /// Second element (if exists) is the ussually nested navigator node.
  static List<OctopusNode> findAncestorNodes(BuildContext context) {
    BuildContext? element = context;
    final result = <OctopusNode>[];
    while (true) {
      element = element
          ?.getElementForInheritedWidgetOfExactType<InheritedOctopusRoute>();
      if (element case OctopusRouteContext routeContext) {
        result.add(routeContext.node);
        element?.visitAncestorElements((parent) {
          element = parent;
          return false;
        });
        continue;
      }
      break;
    }
    return result;
  }

  /// Node of state.
  final OctopusNode node;

  @override
  bool updateShouldNotify(covariant InheritedOctopusRoute oldWidget) =>
      !identical(node, oldWidget.node) && node != oldWidget.node;

  @override
  InheritedElement createElement() => OctopusRouteContext(this);
}

/// {@template octopus_route_context}
/// Octopus route context.
/// {@endtemplate}
class OctopusRouteContext extends InheritedElement {
  /// {@macro octopus_route_context}
  OctopusRouteContext(InheritedOctopusRoute super.widget);

  @override
  InheritedOctopusRoute get widget => super.widget as InheritedOctopusRoute;

  /// Current node.
  OctopusNode get node => widget.node;

  /// Current route name.
  String get name => node.name;

  /// Arguments of this node.
  Map<String, String> get arguments => node.arguments;

  /// Children of this node
  List<OctopusNode> get children => node.children;
}
