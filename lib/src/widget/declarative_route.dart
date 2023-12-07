// TODO(plugfox): Implement declarative route
@Deprecated('Current not supported')

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:octopus/src/controller/octopus.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/widget/route_context.dart';

/// {@template octopus_declarative_route}
/// OctopusDeclarativeRoute widget.
/// {@endtemplate}
class OctopusDeclarativeRoute extends StatefulWidget {
  /// {@macro octopus_declarative_route}
  const OctopusDeclarativeRoute({required this.route, this.builder, super.key});

  /// Name of node.
  final OctopusRoute route;

  /// Builder of route.
  /// If omitted, used routes builder from router delegate instead.
  final WidgetBuilder? builder;

  @override
  State<OctopusDeclarativeRoute> createState() =>
      _OctopusDeclarativeRouteState();
}

class _OctopusDeclarativeRouteState extends State<OctopusDeclarativeRoute> {
  late final Octopus _router;
  late OctopusNode _parentNode;

  @override
  void initState() {
    super.initState();
    _router = Octopus.of(context);
    _router.stateObserver.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(covariant OctopusDeclarativeRoute oldWidget) {
    if (oldWidget.route != widget.route) {
      _onStateChanged();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _parentNode = InheritedOctopusRoute.of(context).node;
    _onStateChanged();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _router.stateObserver.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    if (_parentNode.children.any((node) => node.name == widget.route.name))
      return;
    _router.transaction((state) => state);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.route.name;
    final node =
        _parentNode.children.firstWhereOrNull((node) => node.name == name) ??
            OctopusNode$Immutable(
              name: name,
              children: const <OctopusNode>[],
              arguments: const <String, String>{},
            );
    return InheritedOctopusRoute(
      node: node,
      child: Builder(
        builder: (context) =>
            widget.builder?.call(context) ??
            _router.config.routerDelegate.routes[name]
                ?.builder(context, node) ??
            const SizedBox.shrink(),
      ),
    );
  }
}
