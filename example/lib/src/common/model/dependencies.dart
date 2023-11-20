import 'package:example/src/feature/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/widgets.dart' show BuildContext;

/// Dependencies
abstract interface class Dependencies {
  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);
}
