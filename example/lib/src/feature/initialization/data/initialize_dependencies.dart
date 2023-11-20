import 'dart:async';

import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/feature/initialization/data/platform/platform_initialization.dart';
import 'package:l/l.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = $MutableDependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);
      l.v6(
          'Initialization | $currentStep/$totalSteps ($percent%) | "${step.key}"');
      await step.value(dependencies);
    } on Object catch (error, stackTrace) {
      l.e('Initialization failed at step "${step.key}": $error', stackTrace);
      Error.throwWithStackTrace(
          'Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

typedef _InitializationStep = FutureOr<void> Function(
    $MutableDependencies dependencies);
final Map<String, _InitializationStep> _initializationSteps =
    <String, _InitializationStep>{
  'Platform pre-initialization': (_) => $platformInitialization(),
  'Creating app metadata': (_) {},
  'Observer state managment': (_) {},
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},
  'Prepare authentication controller': (_) {},
  'Restore last user': (_) {},
  'Migrate app from previous version': (_) {},
  'Collect logs': (_) {},
  'Log app initialized': (_) {},
};

final class $MutableDependencies implements Dependencies {
  $MutableDependencies() : context = <String, Object?>{};

  /// Initialization context
  final Map<Object?, Object?> context;
}
