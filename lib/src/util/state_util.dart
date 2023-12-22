// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:meta/meta.dart';
import 'package:octopus/src/state/name_regexp.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/util/logs.dart';

/// {@nodoc}
@internal
abstract final class StateUtil {
  /// Convert tree components to location string.
  ///
  /// For example:
  /// ```
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
  /// ```
  ///
  /// to
  ///
  /// ```
  /// Home/
  /// .Shop/
  /// ..Catalog/
  /// ...Category?id=1/
  /// ...Category?id=12}/
  /// ...Brand?name=Apple/
  /// ...Product?id=123&color=green/
  /// ..Basket/
  /// ..Favorites/
  /// .Gallery/
  /// .Camera/
  /// .Account/
  /// ..Profile/
  /// ..Settings
  /// ```
  /// {@nodoc}
  @internal
  static Uri encodeLocation(OctopusState state) =>
      measureSync('encodeLocation', () {
        final segments = <String>[];
        void encodeNode(OctopusNode node, int depth) {
          final prefix = '.' * depth;
          final String name;
          if (node.arguments.isEmpty) {
            name = node.name;
          } else {
            final args = (node.arguments.entries.toList(growable: false)
                  ..sort((a, b) => a.key.compareTo(b.key)))
                .map<String>(
                  (e) => '${Uri.encodeComponent(e.key)}'
                      '='
                      '${Uri.encodeComponent(e.value)}',
                )
                .join('&');
            name = args.isEmpty ? node.name : '${node.name}~$args';
          }

          segments.add('$prefix$name');

          for (final child in node.children) {
            encodeNode(child, depth + 1);
          }
        }

        for (final node in state.children) {
          encodeNode(node, 0);
        }

        return Uri(
          path: '/${segments.where((s) => s.isNotEmpty).join('/')}',
          /* pathSegments: segments, */
          queryParameters: state.arguments.isEmpty ? null : state.arguments,
          //fragment: ,
        );
      });

  /* @internal
  static Future<Uri> encodeLocationAsync(OctopusState state) async {
    final segments = <String>[];
    final stopwatch = Stopwatch()..start();
    try {
      Future<void> encodeNode(OctopusNode node, int depth) async {
        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(Duration.zero);
          stopwatch.reset();
        }
        final prefix = '.' * depth;
        final String name;
        if (node.arguments.isEmpty) {
          name = node.name;
        } else {
          final args = (node.arguments.entries.toList(growable: false)
                ..sort((a, b) => a.key.compareTo(b.key)))
              .map<String>((e) => '${Uri.encodeComponent(e.key)}'
                  '='
                  '${Uri.encodeComponent(e.value)}')
              .join('&');
          name = args.isEmpty ? node.name : '${node.name}~$args';
        }

        segments.add('$prefix$name');

        for (final child in node.children) {
          await encodeNode(child, depth + 1);
        }
      }

      for (final node in state.children) {
        await encodeNode(node, 0);
      }
    } finally {
      stopwatch.stop();
    }
    return Uri(
      pathSegments: segments,
      queryParameters: state.arguments.isEmpty ? null : state.arguments,
    );
  } */

  /// Convert location string to tree components.
  /// {@nodoc}
  @internal
  static OctopusState$Mutable decodeLocation(String location) =>
      stateFromUri(Uri.parse(location));

  static OctopusState$Mutable stateFromUri(Uri uri) => measureSync(
        'stateFromUri',
        () {
          final queryParameters = uri.queryParameters.entries
              .toList(growable: false)
            ..sort((a, b) => a.key.compareTo(b.key));
          final arguments = <String, String>{
            for (final entry in queryParameters) entry.key: entry.value
          };
          final segments = uri.pathSegments;
          if (segments.isEmpty) {
            return OctopusState$Mutable(
              children: <OctopusNode$Mutable>[],
              arguments: arguments,
              intention: OctopusStateIntention.auto,
            );
          } else {
            return OctopusState$Mutable(
              children: _parseSegments(segments.toList(), 0).toList(),
              arguments: arguments,
              intention: OctopusStateIntention.auto,
            );
          }
        },
        arguments: kMeasureEnabled ? {'uri': uri.toString()} : null,
      );

  /// Represent state as string tree.
  /// {@nodoc}
  @internal
  static String stateToString(OctopusState state) =>
      measureSync('stateToString', () {
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

        for (final node in state.children) {
          add(node, '', '');
        }
        return buffer.toString();
      });

  static Iterable<OctopusNode$Mutable> _parseSegments(
    List<String> segments,
    int depth,
  ) sync* {
    while (segments.isNotEmpty) {
      var segment = segments.removeAt(0);
      try {
        var currentDepth = 0;
        while (currentDepth < segment.length && segment[currentDepth] == '.') {
          currentDepth++;
        }

        if (currentDepth < depth) {
          segments.insert(0, segment);
          break;
        }

        segment = segment.substring(currentDepth);
        final delimiter = segment.indexOf('~');
        final name =
            delimiter == -1 ? segment : segment.substring(0, delimiter);

        if (name.isEmpty || !name.contains($nameRegExp)) {
          assert(false, 'Invalid route name: "$name"');
          continue;
        }

        final Map<String, String> arguments;
        if (delimiter == -1) {
          arguments = <String, String>{};
        } else {
          final query = segment.substring(delimiter + 1);
          final queurySegments = query.split('&');
          final queryParameters =
              queurySegments.fold(<String, String>{}, (result, element) {
            try {
              if (element.length < 2) return result;
              final index = element.indexOf('=');
              if (index == 0) return result;
              final String key;
              final String value;
              if (index == -1) {
                key = _decodeComponent(element);
                value = '';
              } else {
                key = _decodeComponent(element.substring(0, index));
                value = _decodeComponent(element.substring(index + 1));
              }
              if (result[key] case String currentValue) {
                if (currentValue.isEmpty) {
                  result[key] = value;
                } else {
                  result[key] = '$currentValue; $value';
                }
              } else {
                result[key] = value;
              }
              return result;
            } on Object {
              return result;
            }
          });
          final entries = queryParameters.entries.toList(growable: false)
            ..sort((a, b) => a.key.compareTo(b.key));
          arguments = <String, String>{
            for (final entry in entries) entry.key: entry.value
          };
        }
        var children = currentDepth < segment.length - 1
            ? _parseSegments(segments, currentDepth + 1).toList()
            : <OctopusNode>[];
        yield OctopusNode$Mutable(
          name: name,
          arguments: arguments,
          children: children,
        );
      } on Object {
        if (kDebugMode) rethrow;
        continue; // Ignore decode errors in release mode.
      }
    }
  }

  static String _decodeComponent(String component) {
    try {
      if (component.codeUnits.any((e) => e > 127)) return component;
      return Uri.decodeComponent(component);
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return component;
    } on FormatException {
      return component;
    } on Object {
      return component;
    }
  }

  /// Normalize state and exclude duplicates if exist.
  static OctopusState$Immutable normalize(OctopusState state) {
    final mutable = state.isMutable ? state : state.mutate();

    List<OctopusNode> normalizeChildren(List<OctopusNode> nodes) {
      final keys = <String>{};
      final result = <OctopusNode>[];
      for (final node in nodes) {
        // Normalize children.
        final children = normalizeChildren(node.children);

        // Exclude arguments with invalid keys.
        var arguments = node.arguments;
        if (arguments.keys
            .any((key) => key.isEmpty || !key.contains($nameRegExp))) {
          arguments = <String, String>{
            for (final entry in arguments.entries)
              if (entry.key.isNotEmpty && entry.key.contains($nameRegExp))
                entry.key: entry.value
          };
        }

        // Convert to immutable node.
        final newNode = OctopusNode$Immutable(
          name: node.name,
          children: children,
          arguments: arguments,
        );

        // Exclude duplicates by key.
        if (!keys.add(newNode.key)) continue;
        result.add(newNode);
      }
      return result;
    }

    return OctopusState$Immutable(
      children: normalizeChildren(state.children),
      arguments: mutable.arguments,
      intention: state.intention,
    );
  }

  /// Extract node from state by ancestors path.
  /// That method allow find nodes by path.
  /// Path received from `InheritedOctopusRoute.findAncestorNodes`.
  /// Parents goes from root to leaf.
  static OctopusNode? extractNodeFromStateByPath(
    OctopusState state,
    List<OctopusNode> path,
  ) {
    if (path.isEmpty) return null;
    OctopusNode? result;
    var candidates = state.children;
    for (final node in path) {
      candidates =
          candidates.where((e) => e.name == node.name).toList(growable: false);
      if (candidates.length > 1) {
        candidates =
            candidates.where((e) => e.key == node.key).toList(growable: false);
      }
      if (candidates.length != 1) return null; // Not found.
      result = candidates.single;
      candidates = result.children;
    }
    return result;
  }
}
