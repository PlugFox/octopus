import 'dart:async';

/* import 'package:database/database.dart'; */
import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/common/util/error_util.dart';
import 'package:example/src/feature/initialization/data/initialize_dependencies.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Ephemerally initializes the app and prepares it for use.
Future<Dependencies>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<Dependencies> $initializeApp({
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) =>
    _$initializeApp ??= Future<Dependencies>(() async {
      late final WidgetsBinding binding;
      final stopwatch = Stopwatch()..start();
      try {
        binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
        /* await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]); */
        await _catchExceptions();
        final dependencies =
            await $initializeDependencies(onProgress: onProgress)
                .timeout(const Duration(minutes: 7));
        await onSuccess?.call(dependencies);
        return dependencies;
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace);
        ErrorUtil.logError(error, stackTrace, hint: 'Failed to initialize app')
            .ignore();
        rethrow;
      } finally {
        stopwatch.stop();
        binding.addPostFrameCallback((_) {
          // Closes splash screen, and show the app layout.
          binding.allowFirstFrame();
          //final context = binding.renderViewElement;
        });
        _$initializeApp = null;
      }
    });

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp(Dependencies dependencies) async {}

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp(Dependencies dependencies) async {}

Future<void> _catchExceptions() async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      ErrorUtil.logError(
        error,
        stackTrace,
        hint: 'ROOT ERROR\r\n${Error.safeToString(error)}',
      ).ignore();
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      ErrorUtil.logError(
        details.exception,
        details.stack ?? StackTrace.current,
        hint: 'FLUTTER ERROR\r\n$details',
      ).ignore();
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    ErrorUtil.logError(error, stackTrace).ignore();
  }
}
