import 'package:flutter/widgets.dart' show BuildContext;
import 'package:octopus/src/controller/controller.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/widget/inherited_octopus.dart';

/// Extension methods for [BuildContext].
extension OctopusBuildContextExtension on BuildContext {
  /// Receives the [Octopus] instance from the elements tree.
  Octopus get octopus => InheritedOctopus.of(this, listen: false).octopus;

  /// Receives the current [OctopusState] instance from the elements tree.
  OctopusState$Immutable get readOctopusState =>
      InheritedOctopus.of(this, listen: false).state;

  /// Receives the current [OctopusState] instance from the elements tree
  /// and listen for changes.
  OctopusState$Immutable get watchOctopusState =>
      InheritedOctopus.of(this, listen: true).state;
}
