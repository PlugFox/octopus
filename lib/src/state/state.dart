// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
// ignore_for_file: prefer_constructors_over_static_methods
// ignore_for_file: invalid_factory_method_impl
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MaterialPage;
import 'package:flutter/widgets.dart';
import 'package:octopus/src/state/name_regexp.dart';
import 'package:octopus/src/util/jenkins_hash.dart';
import 'package:octopus/src/util/state_util.dart';
import 'package:octopus/src/widget/dialog_page.dart';
import 'package:octopus/src/widget/no_animation.dart';
import 'package:octopus/src/widget/route_context.dart';

/// Signature for the callback to [OctopusNode.visitChildNodes].
///
/// The argument is the child being visited.
///
/// It is safe to call `node.visitChildNodes` reentrantly within
/// this callback.
///
/// Return false to stop the walk.
typedef ConditionalNodeVisitor<Node extends OctopusNode> = bool Function(
  Node node,
);

/// {@template octopus_state}
/// Router whole application state
/// {@endtemplate}
sealed class OctopusState extends OctopusNodeBase {
  /// {@macro octopus_state}
  OctopusState();

  /// Create state from list of nodes
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable from(OctopusState state) =>
      OctopusState$Mutable.from(state);

  /// Create state from single node
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable single(
    OctopusNode node, [
    Map<String, String>? arguments,
  ]) =>
      OctopusState$Mutable(
        children: <OctopusNode$Mutable>[node.mutate()],
        arguments: arguments ?? <String, String>{},
      );

  /// Empty state
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable empty([
    Map<String, String>? arguments,
  ]) =>
      OctopusState$Mutable(
        children: <OctopusNode$Mutable>[],
        arguments: arguments ?? <String, String>{},
      );

  /// Create state from json
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable fromJson(Map<String, Object?> json) {
    final List<OctopusNode$Mutable> children;
    final Map<String, String> arguments;
    // ignore: strict_raw_type
    if (json['children'] case Iterable list) {
      children = <OctopusNode$Mutable>[
        for (final item in list)
          if (item is Map<String, Object?>) OctopusNode.fromJson(item)
      ];
    } else {
      children = <OctopusNode$Mutable>[];
    }
    // ignore: strict_raw_type
    if (json['arguments'] case Map map) {
      arguments = <String, String>{
        for (final entry in map.entries)
          entry.key.toString(): entry.value.toString(),
      };
    } else {
      arguments = <String, String>{};
    }
    return OctopusState$Mutable(
      children: children,
      arguments: arguments,
    );
  }

  /// Create state from location string
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable fromLocation(String location) =>
      StateUtil.decodeLocation(location);

  /// Create state from [Uri]
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable fromUri(Uri uri) =>
      StateUtil.decodeLocation(uri.toString());

  /// Create state from list of nodes
  ///
  /// {@macro octopus_state}
  @factory
  static OctopusState$Mutable fromNodes(
    List<OctopusNode> children, [
    Map<String, String>? arguments,
  ]) =>
      OctopusState$Mutable(
        children: children.map((node) => node.mutate()).toList(),
        arguments: arguments ?? <String, String>{},
      );

  /// Current state representation as a [Uri]
  /// e.g. /shop/category?id=1/category?id=12/product?id=123
  Uri get uri;

  /// Current state representation as a location string.
  String get location;

  /// Returns true if this state has no children.
  bool get isEmpty => children.isEmpty;

  /// Returns true if this state has children.
  bool get isNotEmpty => children.isNotEmpty;

  /// Returns a immutable copy of this state.
  @override
  OctopusState$Immutable freeze();

  /// Returns a mutable copy of this state.
  @override
  OctopusState$Mutable mutate();

  /// Returns a json representation of this state.
  Map<String, Object?> toJson() => <String, Object?>{
        'arguments': arguments,
        'children': children.map((child) => child.toJson()).toList(),
      };

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

/// {@macro octopus_state}
final class OctopusState$Mutable extends OctopusState
    with _OctopusNodeBase$Mutable {
  /// {@macro octopus_state}
  factory OctopusState$Mutable({
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) =>
      OctopusState$Mutable._(
        children: _mutableNodes(children),
        arguments: Map<String, String>.of(arguments),
      );

  /// {@macro octopus_state}
  factory OctopusState$Mutable.from(OctopusState state) => OctopusState$Mutable(
        children: _mutableNodes(state.children),
        arguments: Map<String, String>.of(state.arguments),
      );

  /// {@nodoc}
  OctopusState$Mutable._({
    required this.children,
    required this.arguments,
  });

  @override
  final Map<String, String> arguments;

  @override
  final List<OctopusNode$Mutable> children;

  @override
  Uri get uri => StateUtil.encodeLocation(this);

  @override
  String get location => uri.toString();

  @override
  OctopusState$Immutable freeze() => _freezeState(this);

  @override
  OctopusState$Mutable mutate() => this;

  @override
  OctopusState$Mutable copy() => OctopusState$Mutable(
        children: _mutableNodes(children),
        arguments: Map<String, String>.of(arguments),
      );

  @override
  int get hashCode => location.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is OctopusState) return location == other.location;
    return false;
  }

  @override
  String toString() => StateUtil.stateToString(this);
}

/// {@macro octopus_state}
@immutable
final class OctopusState$Immutable extends OctopusState
    with _OctopusNodeBase$Immutable {
  /// {@macro octopus_state}
  factory OctopusState$Immutable({
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) =>
      OctopusState$Immutable._(
        children: _freezeNodes(children),
        arguments: _freezeArguments(arguments),
      );

  /// {@macro octopus_state}
  factory OctopusState$Immutable.from(OctopusState state) =>
      state is OctopusState$Immutable
          ? state
          : OctopusState$Immutable(
              children: state.children,
              arguments: state.arguments,
            );

  /// {@nodoc}
  OctopusState$Immutable._({
    required this.children,
    required this.arguments,
  });

  @override
  final Map<String, String> arguments;

  @override
  final List<OctopusNode$Immutable> children;

  @override
  late final Uri uri = StateUtil.encodeLocation(this);

  @override
  late final String location = uri.toString();

  @override
  OctopusState$Immutable freeze() => this;

  @override
  OctopusState$Mutable mutate() => OctopusState$Mutable.from(this);

  @override
  OctopusState$Immutable copy() => OctopusState$Immutable(
        children: children,
        arguments: arguments,
      );

  @override
  late final int hashCode = location.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is OctopusState) return location == other.location;
    return false;
  }

  @override
  String toString() => _$representation;
  late final String _$representation = StateUtil.stateToString(this);
}

/// {@template node}
/// Node of the router state tree
/// {@endtemplate}
sealed class OctopusNode extends OctopusNodeBase {
  /// {@macro node}
  OctopusNode();

  /// Create mutable node from json
  ///
  /// {@macro node}
  @factory
  static OctopusNode$Mutable fromJson(Map<String, Object?> json) {
    final String name;
    if (json['name'] case String string) {
      name = string;
    } else {
      throw ArgumentError.value(
        json['name'],
        'name',
        'Should contain a name of the node as a string',
      );
    }
    final List<OctopusNode> children;
    final Map<String, String> arguments;
    // ignore: strict_raw_type
    if (json['children'] case Iterable list) {
      children = <OctopusNode>[
        for (final item in list)
          if (item is Map<String, Object?>) OctopusNode.fromJson(item)
      ];
    } else {
      children = <OctopusNode>[];
    }
    // ignore: strict_raw_type
    if (json['arguments'] case Map map) {
      arguments = <String, String>{
        for (final entry in map.entries)
          entry.key.toString(): entry.value.toString(),
      };
    } else {
      arguments = <String, String>{};
    }
    return OctopusNode$Mutable(
      name: name,
      children: children,
      arguments: arguments,
    );
  }

  /// Create mutable node
  ///
  /// {@macro node}
  @factory
  static OctopusNode$Mutable mutable(
    String name, {
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  }) =>
      OctopusNode$Mutable(
        name: name,
        arguments: arguments ?? <String, String>{},
        children: children ?? <OctopusNode>[],
      );

  /// Create immutable node
  ///
  /// {@macro node}
  @factory
  static OctopusNode$Immutable immutable(
    String name, {
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  }) =>
      OctopusNode$Immutable(
        name: name,
        arguments: arguments ?? const <String, String>{},
        children: children ?? const <OctopusNode>[],
      );

  /// Create mutable node from route
  ///
  /// {@macro node}
  @factory
  static OctopusNode fromRoute(
    OctopusRoute route, {
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  }) =>
      OctopusNode$Mutable(
        name: route.name,
        arguments: arguments ?? <String, String>{},
        children: children ?? <OctopusNode>[],
      );

  /// Identifier of this node based on its [name] and [arguments].
  String get key;

  /// Name of this node.
  /// Should use only alphanumeric characters and dashes.
  /// e.g. my-page
  abstract final String name;

  /// Arguments of this node.
  @override
  abstract final Map<String, String> arguments;

  /// Children of this node
  @override
  abstract final List<OctopusNode> children;

  /// Returns true if this state is immutable.
  @override
  bool get isFrozen;

  /// Returns true if this state is mutable.
  @override
  bool get isMutable;

  /// Returns a mutable copy of this node.
  @override
  OctopusNode$Mutable mutate();

  /// Returns a immutable copy of this node.
  @override
  OctopusNode$Immutable freeze();

  /// Returns a json representation of this node.
  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'arguments': arguments,
        'children': children.map((child) => child.toJson()).toList(),
      };

  /// Returns string representation of this node.
  /// e.g. Category {id: 1}
  @override
  String toString() => arguments.isEmpty ? name : '$name $arguments';
}

/// {@macro node}
final class OctopusNode$Mutable extends OctopusNode
    with _OctopusNodeBase$Mutable {
  /// {@macro node}
  factory OctopusNode$Mutable({
    required String name,
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) =>
      OctopusNode$Mutable._(
        name: name,
        arguments: Map<String, String>.of(arguments),
        children: _mutableNodes(children),
      );

  /// {@macro node}
  factory OctopusNode$Mutable.from(OctopusNode node) => OctopusNode$Mutable(
        name: node.name,
        arguments: Map<String, String>.of(node.arguments),
        children: _mutableNodes(node.children),
      );

  OctopusNode$Mutable._({
    required this.name,
    required this.children,
    required this.arguments,
  })  : assert(
          name.isNotEmpty,
          'Name should not be empty',
        ),
        assert(
          name.contains($nameRegExp),
          'Name should use only alphanumeric characters and dashes',
        );

  @override
  @nonVirtual
  String get key {
    if (arguments.isEmpty) return name;
    final args = arguments.entries
        .map<String>((e) => '${e.key}=${e.value}')
        .toList(growable: false)
      ..sort((a, b) => a.compareTo(b));
    return '$name#${args.join(';')}';
  }

  @override
  String name;

  @override
  final Map<String, String> arguments;

  @override
  final List<OctopusNode$Mutable> children;

  @override
  bool get isMutable => true;

  @override
  bool get isFrozen => false;

  @override
  OctopusNode$Mutable mutate() => this;

  @override
  OctopusNode$Immutable freeze() => OctopusNode$Immutable._(
        name: name,
        children: _freezeNodes(children),
        arguments: _freezeArguments(arguments),
      );

  @override
  OctopusNode$Mutable copy() => OctopusNode$Mutable._(
        name: name,
        children: _mutableNodes(children),
        arguments: Map<String, String>.of(arguments),
      );

  @override
  int get hashCode => jenkinsHashAll([
        name, // Name of the node
        arguments, // Arguments of the node
        children, // Children of the node
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is OctopusNode)
      return name == other.name && hashCode == other.hashCode;
    return false;
  }
}

/// {@macro node}
@immutable
final class OctopusNode$Immutable extends OctopusNode
    with _OctopusNodeBase$Immutable {
  /// {@macro node}
  factory OctopusNode$Immutable({
    required String name,
    required List<OctopusNode> children,
    required Map<String, String> arguments,
  }) =>
      OctopusNode$Immutable._(
        name: name,
        children: _freezeNodes(children),
        arguments: _freezeArguments(arguments),
      );

  OctopusNode$Immutable._({
    required this.name,
    required this.children,
    required this.arguments,
  })  : assert(
          name.isNotEmpty,
          'Name should not be empty',
        ),
        assert(
          name.contains($nameRegExp),
          'Name should use only alphanumeric characters and dashes',
        );

  /// {@macro node}
  factory OctopusNode$Immutable.from(OctopusNode node) => _freezeNode(node);

  @override
  final String name;

  @override
  final Map<String, String> arguments;

  @override
  final List<OctopusNode$Immutable> children;

  @override
  @nonVirtual
  late final String key = arguments.isEmpty
      ? name
      : '$name'
          '#'
          '${arguments.entries.map((e) => '${e.key}=${e.value}').join(';')}';

  @override
  bool get isMutable => false;

  @override
  bool get isFrozen => true;

  @override
  OctopusNode$Mutable mutate() => OctopusNode$Mutable.from(this);

  @override
  OctopusNode$Immutable freeze() => this;

  @override
  OctopusNode$Immutable copy() => OctopusNode$Immutable(
        name: name,
        children: children,
        arguments: arguments,
      );

  @override
  @nonVirtual
  late final int hashCode = jenkinsHashAll([
    name, // Name of the node
    arguments, // Arguments of the node
    children, // Children of the node
  ]);

  @override
  @nonVirtual
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is OctopusNode)
      return name == other.name && hashCode == other.hashCode;
    return false;
  }
}

/// Page builder for routes.
typedef DefaultOctopusPageBuilder = Page<Object?> Function(
  BuildContext context,
  OctopusRoute route,
  OctopusNode node,
);

/// Interface for all routes.
@immutable
mixin OctopusRoute {
  /// Default page builder for all routes.
  static set defaultPageBuilder(DefaultOctopusPageBuilder fn) =>
      _defaultPageBuilder = fn;
  static DefaultOctopusPageBuilder _defaultPageBuilder =
      (context, route, node) => MaterialPage<Object?>(
            key: ValueKey<String>(node.key),
            child: InheritedOctopusRoute(
              node: node,
              child: route.builder(context, node),
            ),
            name: node.name,
            arguments: node.arguments,
            fullscreenDialog: node.name.endsWith('-dialog'),
          );

  /// Slug of this route.
  /// Should use only alphanumeric characters and dashes.
  /// e.g. my-page
  String get name;

  // TODO(plugfox): implement title builder for active route
  /// Title of this route.
  String? get title => null;

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
  ///
  /// If you want to override this method, do not forget to add
  /// [InheritedOctopusRoute] to the element tree.
  Page<Object?> pageBuilder(BuildContext context, OctopusNode node) =>
      node.name.endsWith('-dialog')
          ? OctopusDialogPage(
              key: ValueKey<String>(node.key),
              builder: (context) => builder(context, node),
              name: node.name,
              arguments: node.arguments,
            )
          : NoAnimationScope.of(context)
              ? NoAnimationPage<Object?>(
                  key: ValueKey<String>(node.key),
                  child: InheritedOctopusRoute(
                    node: node,
                    child: builder(context, node),
                  ),
                  name: node.name,
                  arguments: node.arguments,
                  fullscreenDialog: node.name.endsWith('-dialog'),
                )
              : _defaultPageBuilder.call(context, this, node);

  /// Construct [OctopusNode] for this route.
  OctopusNode$Mutable node({
    Map<String, String>? arguments,
    List<OctopusNode>? children,
  }) =>
      OctopusNode$Mutable(
        name: name,
        arguments: arguments ?? <String, String>{},
        children: children ?? <OctopusNode$Mutable>[],
      );
}

/// Base class for all nodes and states.
abstract base class OctopusNodeBase {
  /// Returns true when this entity is immutable.
  bool get isFrozen;

  /// Returns true if this entity is mutable.
  bool get isMutable;

  /// Returns a immutable copy of this entity.
  OctopusNodeBase freeze();

  /// Returns a mutable copy of this entity.
  OctopusNodeBase mutate();

  /// Returns a copy of this entity.
  OctopusNodeBase copy();

  /// Arguments of this entity.
  abstract final Map<String, String> arguments;

  /// Children of this entity
  abstract final List<OctopusNode> children;

  /// Walks the children of this node.
  ///
  /// Return false to stop the walk.
  void visitChildNodes(ConditionalNodeVisitor visitor);

  /// Search element in the current node and its descendants
  /// and get first match or null.
  OctopusNode? find(ConditionalNodeVisitor test);

  /// Search element in the current node and its descendants
  /// and get first match or null by name.
  OctopusNode? findByName(String name);

  /// Search element in the current node and its descendants
  /// and get all matches or null.
  List<OctopusNode> findAll(bool Function(OctopusNode) test);

  /// Walks the children of this node and evaluates [value] on each of them.
  T fold<T>(T value, T Function(T value, OctopusNode node) visitor);
}

/// Mixin for all mutable entities.
/// {@nodoc}
base mixin _OctopusNodeBase$Mutable on OctopusNodeBase {
  @override
  bool get isFrozen => true;

  @override
  bool get isMutable => false;

  @override
  abstract final Map<String, String> arguments;

  @override
  abstract final List<OctopusNode$Mutable> children;

  @override
  void visitChildNodes(ConditionalNodeVisitor<OctopusNode$Mutable> visitor) {
    final queue = Queue<OctopusNode$Mutable>.of(children);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      if (!visitor(node)) return;
      queue.addAll(node.children);
    }
  }

  @override
  OctopusNode$Mutable? find(ConditionalNodeVisitor<OctopusNode$Mutable> test) {
    OctopusNode$Mutable? result;
    visitChildNodes((node) {
      if (!test(node)) return true;
      result = node;
      return false;
    });
    return result;
  }

  @override
  OctopusNode$Mutable? findByName(String name) =>
      find((node) => node.name == name);

  @override
  List<OctopusNode$Mutable> findAll(
      ConditionalNodeVisitor<OctopusNode$Mutable> test) {
    final result = <OctopusNode$Mutable>[];
    visitChildNodes((node) {
      if (!test(node)) return true;
      result.add(node);
      return false;
    });
    return result;
  }

  @override
  T fold<T>(T value, T Function(T value, OctopusNode$Mutable node) visitor) {
    var result = value;
    final queue = Queue<OctopusNode$Mutable>.of(children);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      result = visitor(result, node);
      queue.addAll(node.children);
    }
    return result;
  }

  /// Add new node to the end of the top level children.
  void add(OctopusNode node) => children.add(node.mutate());

  /// Add few nodes to the end of the top level children.
  void addAll(List<OctopusNode> nodes) => children.addAll(_mutableNodes(nodes));

  /// Mutate all nodes with a new one. From leaf to root.
  void replace(OctopusNode Function(OctopusNode$Mutable) fn) {
    void recursion(List<OctopusNode$Mutable> children) {
      for (var i = children.length - 1; i > -1; i--) {
        final value = children[i];
        if (value.children.isNotEmpty) recursion(value.children);
        children[i] = fn(value).mutate();
      }
    }

    recursion(children);
  }

  /// Remove all children that satisfy the given [test].
  void removeWhere(bool Function(OctopusNode$Mutable) test) {
    void fn(List<OctopusNode$Mutable> children) {
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

  /// Remove node with the same [name] and [arguments].
  void remove(OctopusNode node) => removeWhere(
      (n) => n.name == node.name && mapEquals(n.arguments, node.arguments));

  /// Remove node with the same [name].
  void removeByName(String name) => removeWhere((node) => node.name == name);

  /// Remove last child from the node's children.
  OctopusNode? removeLast() {
    if (children.isEmpty) return null;
    return children.removeLast();
  }

  /// Clear all children.
  void clear() => children.clear();
}

/// Mixin for all mutable entities.
/// {@nodoc}
@immutable
base mixin _OctopusNodeBase$Immutable on OctopusNodeBase {
  @override
  bool get isFrozen => true;

  @override
  bool get isMutable => false;

  @override
  abstract final Map<String, String> arguments;

  @override
  abstract final List<OctopusNode$Immutable> children;

  @override
  void visitChildNodes(ConditionalNodeVisitor<OctopusNode$Immutable> visitor) {
    final queue = Queue<OctopusNode$Immutable>.of(children);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      if (!visitor(node)) return;
      queue.addAll(node.children);
    }
  }

  @override
  OctopusNode$Immutable? find(
      ConditionalNodeVisitor<OctopusNode$Immutable> test) {
    OctopusNode$Immutable? result;
    visitChildNodes((node) {
      if (!test(node)) return true;
      result = node;
      return false;
    });
    return result;
  }

  @override
  OctopusNode$Immutable? findByName(String name) =>
      find((node) => node.name == name);

  @override
  List<OctopusNode$Immutable> findAll(
      ConditionalNodeVisitor<OctopusNode$Immutable> test) {
    final result = <OctopusNode$Immutable>[];
    visitChildNodes((node) {
      if (!test(node)) return true;
      result.add(node);
      return false;
    });
    return result;
  }

  @override
  T fold<T>(T value, T Function(T value, OctopusNode$Immutable node) visitor) {
    var result = value;
    final queue = Queue<OctopusNode$Immutable>.of(children);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      result = visitor(result, node);
      queue.addAll(node.children);
    }
    return result;
  }
}

/// Freezes the given [state].
/// If the state is already frozen, it is returned unchanged.
/// {@nodoc}
OctopusState$Immutable _freezeState(OctopusState state) =>
    state is OctopusState$Immutable
        ? state
        : OctopusState$Immutable._(
            children: List<OctopusNode$Immutable>.unmodifiable(
                state.children.map<OctopusNode$Immutable>(_freezeNode)),
            arguments: _freezeArguments(state.arguments),
          );

/// Freezes the given [node].
/// If the node is already frozen, it is returned unchanged.
/// {@nodoc}
OctopusNode$Immutable _freezeNode(OctopusNode node) =>
    node is OctopusNode$Immutable
        ? node
        : OctopusNode$Immutable._(
            name: node.name,
            children: List<OctopusNode$Immutable>.unmodifiable(
                node.children.map<OctopusNode$Immutable>(_freezeNode)),
            arguments: _freezeArguments(node.arguments),
          );

/// Freezes the given [nodes].
/// If the list already contains only frozen nodes, it is returned unchanged.
/// {@nodoc}
List<OctopusNode$Immutable> _freezeNodes(List<OctopusNode> nodes) =>
    nodes is List<OctopusNode$Immutable>
        ? nodes
        : List<OctopusNode$Immutable>.unmodifiable(
            nodes.map<OctopusNode$Immutable>(_freezeNode));

/// Returns a mutable copy of the given [nodes].
/// {@nodoc}
List<OctopusNode$Mutable> _mutableNodes(List<OctopusNode> nodes) =>
    nodes.map<OctopusNode$Mutable>(OctopusNode$Mutable.from).toList();

Map<String, String> _freezeArguments(Map<String, String> arguments) {
  if (arguments.isEmpty) return const <String, String>{};
  if (arguments is UnmodifiableMapBase<String, String>) return arguments;
  assert(
    !arguments.keys.any((key) => !key.contains($nameRegExp)),
    'Invalid argument name',
  );
  final entries = arguments.entries.toList(growable: false)
    ..sort((a, b) => a.key.compareTo(b.key));
  return Map<String, String>.unmodifiable(
    <String, String>{for (final entry in entries) entry.key: entry.value},
  );
}
