import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/utils/location_util.dart';
import 'package:octopus/src/widget/route_context.dart';

/// Signature for the callback to [OctopusNode.visitChildNodes].
///
/// The argument is the child being visited.
///
/// It is safe to call `node.visitChildNodes` reentrantly within
/// this callback.
typedef NodeVisitor = void Function(OctopusNode element);

/// {@template octopus_state}
/// Router whole application state
/// {@endtemplate}
@immutable
sealed class OctopusState extends _OctopusTree {
  /// Current state representation as a location string.
  /// e.g. /shop/category?id=1/category?id=12/product?id=123
  Uri get uri;

  /// Convert this state to JSON.
  Map<String, Object?> toJson();
}

/// Node of the router state tree
class OctopusNode extends _OctopusTree {
  /// Node of the router state tree
  OctopusNode({
    required this.name,
    this.arguments = const <String, String>{},
    this.children = const <OctopusNode>[],
  })  : assert(
          name.isNotEmpty,
          'Name should not be empty',
        ),
        assert(
          name.contains(RegExp(r'^[a-zA-Z0-9\-]+$')),
          'Name should use only alphanumeric characters and dashes',
        );

  /// Name of this node.
  /// Should use only alphanumeric characters and dashes.
  /// e.g. my-page
  final String name;

  /// Arguments of this node.
  @override
  final Map<String, String> arguments;

  /// Children of this node
  @override
  final List<OctopusNode> children;

  /* String get location => Uri.encodeQueryComponent(
        name,
        encoding: utf8,
      ); */

  /// Returns string representation of this node.
  /// e.g. Category {id: 1}
  @override
  String toString() => '$name${arguments.isEmpty ? '' : ' $arguments'}';
}

/// Interface for all routes.
@immutable
abstract class OctopusRoute {
  /// Slug of this route.
  /// Should use only alphanumeric characters and dashes.
  /// e.g. my-page
  abstract final String name;

  /// Build [Widget] for this route using [OctopusRouteContext].
  /// Use [OctopusRouteContext] to access current route information,
  /// arguments and its children.
  ///
  /// e.g.
  /// ```dart
  /// context.node;
  /// context.name;
  /// context.arguments;
  /// context.children;
  /// ```
  Page<Object?> builder(OctopusRouteContext context);

  /// Construct [OctopusNode] for this route.
  OctopusNode node({
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  }) =>
      OctopusNode(
        name: name,
        arguments: arguments ?? const <String, String>{},
        children: children ?? const <OctopusNode>[],
      );
}

/// {@nodoc}
@internal
@immutable
final class OctopusStateImmutable extends OctopusState
    with _OctopusStateToString {
  /// {@nodoc}
  OctopusStateImmutable({
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  })  : children = children is UnmodifiableListView<OctopusNode>
            ? children
            : UnmodifiableListView<OctopusNode>(children),
        arguments = arguments is UnmodifiableMapView<String, String>
            ? arguments
            : UnmodifiableMapView<String, String>(arguments);

  @override
  final List<OctopusNode> children;

  @override
  final Map<String, String> arguments;

  @override
  late Uri uri = LocationUtil.encodeLocation(this);

  @override
  Map<String, Object?> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

abstract class _OctopusTree {
  /// Children of this entity
  abstract final List<OctopusNode> children;

  /// Arguments of this entity.
  abstract final Map<String, String> arguments;

  /// Walks the children of this node.
  void visitChildNodes(NodeVisitor visitor) => children.forEach(visitor);
}

base mixin _OctopusStateToString on OctopusState {
  /// Returns a string representation of this node and its descendants.
  /// e.g.
  /// Home
  /// ├── Shop
  /// │   ├── Catalog
  /// │   │   ├── Category {id: 1}
  /// │   │   ├── Category {id: 12}
  /// │   │   ├── Brand {name: Apple}
  /// │   │   └── Product {id: 123, color: green}
  /// │   ├── Basket
  /// │   └── Favorites
  /// ├── Gallery
  /// ├── Camera
  /// └── Account
  ///     ├── Profile
  ///     └── Settings
  @override
  String toString() {
    final buffer = StringBuffer();
    void add(OctopusNode node, String prefix, String childPrefix) {
      buffer
        ..write(prefix)
        ..write(node.name);
      if (node.arguments.isNotEmpty) {
        buffer
          ..write(' ')
          ..write(node.arguments);
      }
      buffer.writeln();
      for (var i = 0; i < node.children.length; i++) {
        var child = node.children[i];
        var isLast = i == node.children.length - 1;
        if (isLast) {
          add(
            child,
            '$childPrefix└─',
            '$childPrefix  ',
          );
        } else {
          add(
            child,
            '$childPrefix├─',
            '$childPrefix│ ',
          );
        }
      }
    }

    for (final node in children) {
      add(node, '', '');
    }
    return buffer.toString();
  }
}
