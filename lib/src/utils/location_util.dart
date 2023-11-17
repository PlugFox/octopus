// ignore_for_file: avoid_classes_with_only_static_members

import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';

/// {@nodoc}
@internal
abstract final class LocationUtil {
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
  static Uri encodeLocation(OctopusState state) {
    final segments = <String>[];
    void encodeNode(OctopusNode node, int depth) {
      final prefix = '.' * depth;
      final args = node.arguments.entries
          .map<String>((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final name = args.isEmpty ? node.name : '${node.name}~$args';

      segments.add('$prefix$name');

      for (final child in node.children) {
        encodeNode(child, depth + 1);
      }
    }

    for (final node in state.children) {
      encodeNode(node, 0);
    }

    return Uri(
      pathSegments: segments,
      queryParameters: state.arguments.isEmpty ? null : state.arguments,
    );
  }

  /// Convert location string to tree components.
  /// {@nodoc}
  @internal
  static OctopusState decodeLocation(String location) {
    final arguments = <String, String>{};
    final segments =
        location.replaceAll('\n', '').replaceAll(r'\', '/').trim().split('/');
    if (segments.isEmpty) {
      return OctopusStateImmutable(
        children: const <OctopusNode>[],
        arguments: arguments,
      );
    }

    Iterable<OctopusNode> parseSegments(
      List<String> segments,
      int depth,
    ) sync* {
      while (segments.isNotEmpty) {
        var segment = segments.first;
        segments.removeAt(0);

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
        final args = delimiter == -1
            ? const <String, String>{}
            : Uri.splitQueryString(segment.substring(delimiter + 1));

        var children = currentDepth < segment.length - 1
            ? parseSegments(segments, currentDepth + 1).toList(growable: false)
            : const <OctopusNode>[];
        yield OctopusNode(name: name, arguments: args, children: children);
      }
    }

    return OctopusStateImmutable(
      children: parseSegments(segments, 0).toList(growable: false),
      arguments: arguments,
    );
  }
}
