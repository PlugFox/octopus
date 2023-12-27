import 'package:flutter/material.dart';
import 'package:octopus/src/controller/controller.dart';
import 'package:octopus/src/state/state.dart';

/// InheritedOctopus widget.
/// {@nodoc}
class InheritedOctopus extends InheritedWidget {
  /// {@nodoc}
  const InheritedOctopus({
    required super.child,
    required this.octopus,
    required this.state,
    super.key, // ignore: unused_element
  });

  /// Receives the [Octopus] instance from the elements tree.
  /// {@nodoc}
  final Octopus octopus;

  /// Receives the [OctopusState] instance from the elements tree.
  /// {@nodoc}
  final OctopusState$Immutable state;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `InheritedOctopus.maybeOf(context)`.
  /// {@nodoc}
  static InheritedOctopus? maybeOf(BuildContext context,
          {bool listen = true}) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<InheritedOctopus>()
          : context.getInheritedWidgetOfExactType<InheritedOctopus>();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a InheritedOctopus of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `InheritedOctopus.of(context)`
  /// {@nodoc}
  static InheritedOctopus of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant InheritedOctopus oldWidget) =>
      state != oldWidget.state;
}
