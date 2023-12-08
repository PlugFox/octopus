import 'package:example/src/common/model/dependencies.dart';
import 'package:flutter/material.dart';

/// {@template inherited_dependencies}
/// InheritedDependencies widget.
/// {@endtemplate}
class InheritedDependencies extends InheritedWidget {
  /// {@macro inherited_dependencies}
  const InheritedDependencies({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final Dependencies dependencies;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `InheritedDependencies.maybeOf(context)`.
  static Dependencies? maybeOf(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<InheritedDependencies>()
          ?.widget as InheritedDependencies?)
      ?.dependencies;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a InheritedDependencies of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `InheritedDependencies.of(context)`
  static Dependencies of(BuildContext context) =>
      maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(InheritedDependencies oldWidget) => false;
}
