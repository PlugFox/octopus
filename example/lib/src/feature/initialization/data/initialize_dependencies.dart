import 'dart:async';

import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/feature/authentication/controller/authentication_controller.dart';
import 'package:example/src/feature/authentication/data/authentication_repository.dart';
import 'package:example/src/feature/initialization/data/platform/platform_initialization.dart';
import 'package:example/src/feature/shop/controller/shop_controller.dart';
import 'package:example/src/feature/shop/data/product_repository.dart';
import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = Dependencies();
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
    Dependencies dependencies);
final Map<String, _InitializationStep> _initializationSteps =
    <String, _InitializationStep>{
  'Platform pre-initialization': (_) => $platformInitialization(),
  'Creating app metadata': (_) {},
  'Observer state managment': (_) {},
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},
  'Initialize shared preferences': (dependencies) async =>
      dependencies.sharedPreferences = await SharedPreferences.getInstance(),
  'Prepare authentication controller': (dependencies) =>
      dependencies.authenticationController = AuthenticationController(
        repository: AuthenticationRepositoryImpl(
          sharedPreferences: dependencies.sharedPreferences,
        ),
      ),
  'Restore last user': (dependencies) =>
      dependencies.authenticationController.restore(),
  'Prepare shop controller': (dependencies) =>
      dependencies.shopController = ShopController(
        repository: ProductRepositoryImpl(),
      )..fetch(),
  'Migrate app from previous version': (_) {},
  'Collect logs': (_) {},
  'Log app initialized': (_) {},
};
