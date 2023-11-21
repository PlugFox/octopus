import 'dart:collection';

import 'package:flutter/material.dart' show MaterialPage;
import 'package:flutter/widgets.dart';
import 'package:octopus/src/utils/state_util.dart';

/// Signature for the callback to [OctopusNode.visitChildNodes].
///
/// The argument is the child being visited.
///
/// It is safe to call `node.visitChildNodes` reentrantly within
/// this callback.
///
/// Return false to stop the walk.
typedef ConditionalNodeVisitor = bool Function(OctopusNode element);

/// {@template octopus_state}
/// Router whole application state
/// {@endtemplate}
class OctopusState extends _OctopusTree with _OctopusStateMethods {
  /// {@macro octopus_state}
  OctopusState({
    required this.children,
    required this.arguments,
  });

  /// {@macro octopus_state}
  factory OctopusState.fromUri(Uri uri) =>
      StateUtil.decodeLocation(uri.toString());

  /// {@macro octopus_state}
  factory OctopusState.fromLocation(String location) =>
      StateUtil.decodeLocation(location);

  /// Current state representation as a [Uri]
  /// e.g. /shop/category?id=1/category?id=12/product?id=123
  Uri get uri => StateUtil.encodeLocation(this);

  /// Current state representation as a location string.
  String get location => uri.toString();

  @override
  final List<OctopusNode> children;

  @override
  final Map<String, String> arguments;

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
  /// └── Account
  ///     ├── Profile
  ///     └── Settings
  @override
  String toString() => StateUtil.stateToString(this);
}

/// Node of the router state tree
class OctopusNode extends _OctopusTree {
  /// Node of the router state tree
  OctopusNode({
    required this.name,
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  })  : assert(
          name.isNotEmpty,
          'Name should not be empty',
        ),
        assert(
          name.contains(RegExp(r'^[a-zA-Z0-9\-]+$')),
          'Name should use only alphanumeric characters and dashes',
        ),
        children = children ?? <OctopusNode>[],
        arguments = arguments ?? <String, String>{};

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

  /// Returns a copy of this node.
  OctopusNode copy() => OctopusNode(
        name: name,
        children: children.map<OctopusNode>((child) => child.copy()).toList(),
        arguments: Map<String, String>.of(arguments),
      );

  /// Returns string representation of this node.
  /// e.g. Category {id: 1}
  @override
  String toString() => arguments.isEmpty ? name : '$name $arguments';
}

/// Interface for all routes.
@immutable
mixin OctopusRoute {
  /// Slug of this route.
  /// Should use only alphanumeric characters and dashes.
  /// e.g. my-page
  String get name;

  /// Build [Widget] for this route using [BuildContext] and [OctopusNode].
  ///
  /// Use [OctopusNode] to access current route information,
  /// arguments and its children.
  ///
  /// e.g.
  /// ```dart
  /// final OctopusNode(:name, :arguments, :children) = node;
  /// ```
  Widget builder(BuildContext context, OctopusNode node);

  /// Build [Page] for this route using [BuildContext] and [OctopusNode].
  /// [BuildContext] - Navigator context.
  /// [OctopusNode] - Current node of the router state tree.
  Page<Object?> pageBuilder(BuildContext context, OctopusNode node) {
    final OctopusNode(:name, arguments: args) = node;
    final key = ValueKey<String>(
      args.isEmpty
          ? name
          : '$name'
              '#'
              '${args.entries.map((e) => '${e.key}=${e.value}').join(';')}',
    );
    return MaterialPage<Object?>(
      key: key,
      child: builder(context, node),
      name: name,
      arguments: args,
    );
  }

  /// Construct [OctopusNode] for this route.
  OctopusNode node({
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  }) =>
      OctopusNode(
        name: name,
        arguments: arguments ?? <String, String>{},
        children: children ?? <OctopusNode>[],
      );
}

abstract class _OctopusTree {
  /// Children of this entity
  abstract final List<OctopusNode> children;

  /// Arguments of this entity.
  abstract final Map<String, String> arguments;

  /// Walks the children of this node.
  ///
  /// Return false to stop the walk.
  void visitChildNodes(ConditionalNodeVisitor visitor) {
    final queue = Queue<OctopusNode>.of(children);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      if (!visitor(node)) return;
      queue.addAll(node.children);
    }
  }
}

mixin _OctopusStateMethods on _OctopusTree {
  /// Returns a copy of this state using [fn] function as a transformer
  OctopusState copy() => OctopusState(
        children: children.map<OctopusNode>((child) => child.copy()).toList(),
        arguments: Map<String, String>.of(arguments),
      );

  /// Remove all children that satisfy the given [test].
  void removeWhere(bool Function(OctopusNode) test) {
    void fn(List<OctopusNode> children) {
      for (var i = children.length - 1; i > -1; i--) {
        final value = children[i];
        if (test(value)) {
          children.removeAt(i);
        } else if (value.children.isNotEmpty) {
          fn(value.children);
        }
      }
    }

    fn(children);
  }

  /// Search element in whole state tree
  OctopusNode? firstWhereOrNull(bool Function(OctopusNode) test) {
    OctopusNode? result;
    visitChildNodes((node) {
      if (!test(node)) return true;
      result = node;
      return false;
    });
    return result;
  }

  /// Clear all children
  void clear() => children.clear();

  /// Pop last node from the end of the state tree
  OctopusNode? maybePop() {
    if (children.isEmpty) return null;
    var list = children;
    while (list.isNotEmpty && list.last.children.isNotEmpty) {
      list = list.last.children;
    }
    return list.removeLast();
  }

  /// Push new node to the end of the state tree
  void push(OctopusNode node) {
    var list = children;
    while (list.isNotEmpty && list.last.children.isNotEmpty) {
      list = list.last.children;
    }
    list.add(node);
  }

  /// Add few nodes to the end of the state tree
  void pushAll(List<OctopusNode> nodes) {
    var list = children;
    while (list.isNotEmpty && list.last.children.isNotEmpty) {
      list = list.last.children;
    }
    list.addAll(nodes);
  }

  /// Mutate all nodes with a new one.
  /// From leaf (newer) to root (older).
  void replace(OctopusNode Function(OctopusNode) fn) {
    void recursion(List<OctopusNode> children) {
      for (var i = children.length - 1; i > -1; i--) {
        final value = children[i];
        if (value.children.isNotEmpty) recursion(value.children);
        children[i] = fn(value);
      }
    }

    recursion(children);
  }

  /// Replace all nodes that satisfy the given [test] with [node].
  void replaceWhere(OctopusNode node, bool Function(OctopusNode) test) {
    void fn(List<OctopusNode> children) {
      for (var i = children.length - 1; i > -1; i--) {
        final value = children[i];
        if (test(value)) {
          children[i] = node;
        } else if (value.children.isNotEmpty) {
          fn(value.children);
        }
      }
    }

    fn(children);
  }

  // TODO(plugfox):
  /// PushTo
  /// Pop
  /// PopFrom
  /// Activate
}
