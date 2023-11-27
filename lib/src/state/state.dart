import 'dart:collection';

import 'package:flutter/material.dart' show MaterialPage;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state_util.dart';

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
abstract class OctopusState extends _OctopusTree {
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
  Uri get uri;

  /// Current state representation as a location string.
  String get location;

  @override
  final List<OctopusNode> children;

  @override
  final Map<String, String> arguments;

  /// Returns true if this state has no children.
  bool get isEmpty => children.isEmpty;

  /// Returns true if this state has children.
  bool get isNotEmpty => children.isNotEmpty;

  /// Returns a immutable copy of this state.
  OctopusState freeze();

  /// Returns a mutable copy of this state.
  OctopusState mutate();

  /// Remove all children that satisfy the given [test].
  void removeWhere(bool Function(OctopusNode) test);

  /// Search element in whole state tree
  OctopusNode? firstWhereOrNull(bool Function(OctopusNode) test);

  /// Clear all children
  void clear();

  /// Pop last node from the end of the state tree
  OctopusNode? maybePop();

  /// Push new node to the end of the state tree
  void push(OctopusNode node);

  /// Add few nodes to the end of the state tree
  void pushAll(List<OctopusNode> nodes);

  /// Mutate all nodes with a new one.
  /// From leaf (newer) to root (older).
  void replace(OctopusNode Function(OctopusNode) fn);

  /// Replace all nodes that satisfy the given [test] with [node].
  void replaceWhere(OctopusNode node, bool Function(OctopusNode) test);

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
  String toString();
}

/// {@nodoc}
@internal
class OctopusState$Mutable extends OctopusState
    with _OctopusStateMutableMethods {
  /// {@nodoc}
  OctopusState$Mutable({
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) : super(
          children: children,
          arguments: arguments,
        );

  factory OctopusState$Mutable.from(OctopusState state) => OctopusState$Mutable(
        children:
            state.children.map<OctopusNode>((child) => child.mutate()).toList(),
        arguments: Map<String, String>.of(state.arguments),
      );

  @override
  bool get isFrozen => false;

  @override
  bool get isMutable => true;

  @override
  Uri get uri => StateUtil.encodeLocation(this);

  @override
  String get location => uri.toString();

  @override
  OctopusState$Immutable freeze() => OctopusState$Immutable(
        children: children,
        arguments: arguments,
      );

  @override
  OctopusState$Mutable mutate() => this;

  @override
  String toString() => StateUtil.stateToString(this);
}

/// {@nodoc}
@internal
@immutable
class OctopusState$Immutable extends OctopusState
    with _OctopusStateImmutableMethods {
  /// {@nodoc}
  OctopusState$Immutable({
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) : super(
          children: List<OctopusNode>.unmodifiable(
            children.map<OctopusNode>(_freezeNode),
          ),
          arguments: Map<String, String>.unmodifiable(arguments),
        );

  factory OctopusState$Immutable.from(OctopusState state) =>
      state is OctopusState$Immutable
          ? state
          : OctopusState$Immutable(
              children: state.children,
              arguments: state.arguments,
            );

  static OctopusNode$Immutable _freezeNode(OctopusNode node) =>
      node is OctopusNode$Immutable
          ? node
          : OctopusNode$Immutable(
              name: node.name,
              children: node.children,
              arguments: node.arguments,
            );

  @override
  bool get isFrozen => true;

  @override
  bool get isMutable => false;

  @override
  late final Uri uri = StateUtil.encodeLocation(this);

  @override
  late final String location = uri.toString();

  @override
  OctopusState$Immutable freeze() => this;

  @override
  OctopusState$Mutable mutate() => OctopusState$Mutable.from(this);

  @override
  late final int hashCode = location.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is OctopusState$Immutable) return location == other.location;
    return false;
  }

  late final String _$representation = StateUtil.stateToString(this);
  @override
  String toString() => _$representation;
}

/// Node of the router state tree
abstract class OctopusNode extends _OctopusTree {
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

  /// Returns true if this state is immutable.
  @override
  bool get isFrozen;

  /// Returns true if this state is mutable.
  @override
  bool get isMutable;

  /// Returns a mutable copy of this node.
  OctopusNode mutate();

  /// Returns a immutable copy of this node.
  OctopusNode freeze();

  /// Returns string representation of this node.
  /// e.g. Category {id: 1}
  @override
  String toString() => arguments.isEmpty ? name : '$name $arguments';
}

/// {@nodoc}
@internal
class OctopusNode$Mutable extends OctopusNode {
  /// {@nodoc}
  OctopusNode$Mutable({
    required String name,
    required Map<String, String> arguments,
    required List<OctopusNode> children,
  }) : super(
          name: name,
          arguments: Map<String, String>.of(arguments),
          children:
              children.map<OctopusNode>(OctopusNode$Mutable.from).toList(),
        );

  /// {@nodoc}
  factory OctopusNode$Mutable.from(OctopusNode node) => OctopusNode$Mutable(
        name: node.name,
        arguments: Map<String, String>.of(node.arguments),
        children: node.children.map(OctopusNode$Mutable.from).toList(),
      );

  @override
  bool get isMutable => true;

  @override
  bool get isFrozen => false;

  @override
  OctopusNode mutate() => OctopusNode$Mutable.from(this);

  /// Returns a immutable copy of this node.
  @override
  OctopusNode freeze() => OctopusNode$Immutable(
        name: name,
        children: children,
        arguments: arguments,
      );
}

/// {@nodoc}
@internal
@immutable
class OctopusNode$Immutable extends OctopusNode {
  /// {@nodoc}
  OctopusNode$Immutable({
    required String name,
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) : super(
          name: name,
          children: List<OctopusNode>.unmodifiable(children.map<OctopusNode>(
            (node) => node.freeze(),
          )),
          arguments: Map<String, String>.unmodifiable(arguments),
        );

  /// {@nodoc}
  factory OctopusNode$Immutable.from(OctopusNode node) =>
      node is OctopusNode$Immutable
          ? node
          : OctopusNode$Immutable(
              name: node.name,
              children: node.children,
              arguments: node.arguments,
            );

  @override
  bool get isMutable => false;

  @override
  bool get isFrozen => true;

  @override
  OctopusNode mutate() => OctopusNode$Mutable.from(this);

  /// Returns a immutable copy of this node.
  @override
  OctopusNode freeze() => this;

  @override
  late final int hashCode = Object.hashAll([
    name,
    for (final entry in arguments.entries) '${entry.key}=${entry.value};',
    for (final child in children) child.hashCode,
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is OctopusNode$Immutable) return hashCode == other.hashCode;
    return false;
  }
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
      OctopusNode$Mutable(
        name: name,
        arguments: arguments ?? <String, String>{},
        children: children ?? <OctopusNode>[],
      );
}

abstract class _OctopusTree {
  /// Returns true when this entity is immutable.
  bool get isFrozen;

  /// Returns true if this entity is mutable.
  bool get isMutable;

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

mixin _OctopusStateMutableMethods on OctopusState {
  /* OctopusState _mutate(void Function(OctopusState state) fn) {
    final OctopusState$Mutable state;
    if (this is OctopusState$Mutable) {
      state = this as OctopusState$Mutable;
    } else {
      state = OctopusState$Mutable(
        children: children.map<OctopusNode>((child) => child.mutate()).toList(),
        arguments: Map<String, String>.of(arguments),
      );
    }
    fn(state);
    return state;
  } */

  @override
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

  @override
  OctopusNode? firstWhereOrNull(bool Function(OctopusNode) test) {
    OctopusNode? result;
    visitChildNodes((node) {
      if (!test(node)) return true;
      result = node;
      return false;
    });
    return result;
  }

  @override
  void clear() => children.clear();

  @override
  OctopusNode? maybePop() {
    if (children.isEmpty) return null;
    var list = children;
    while (list.isNotEmpty && list.last.children.isNotEmpty) {
      list = list.last.children;
    }
    return list.removeLast();
  }

  @override
  void push(OctopusNode node) {
    var list = children;
    while (list.isNotEmpty && list.last.children.isNotEmpty) {
      list = list.last.children;
    }
    list.add(node);
  }

  @override
  void pushAll(List<OctopusNode> nodes) {
    var list = children;
    while (list.isNotEmpty && list.last.children.isNotEmpty) {
      list = list.last.children;
    }
    list.addAll(nodes);
  }

  @override
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

  @override
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

mixin _OctopusStateImmutableMethods on OctopusState {
  @override
  OctopusNode? firstWhereOrNull(bool Function(OctopusNode p1) test) {
    OctopusNode? result;
    visitChildNodes((node) {
      if (!test(node)) return true;
      result = node;
      return false;
    });
    return result;
  }

  static Never _throwImmutableException() => throw UnsupportedError(
        'This state is immutable, '
        'use mutable copy with `mutate()` method to alter it.',
      );

  @override
  void clear() => _throwImmutableException();

  @override
  OctopusNode? maybePop() => _throwImmutableException();

  @override
  void push(OctopusNode node) => _throwImmutableException();

  @override
  void pushAll(List<OctopusNode> nodes) => _throwImmutableException();

  @override
  void removeWhere(bool Function(OctopusNode p1) test) =>
      _throwImmutableException();

  @override
  void replace(OctopusNode Function(OctopusNode p1) fn) =>
      _throwImmutableException();

  @override
  void replaceWhere(OctopusNode node, bool Function(OctopusNode p1) test) =>
      _throwImmutableException();
}
