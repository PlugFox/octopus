import 'dart:async';

import 'package:example/src/common/util/error_util.dart';
import 'package:example/src/common/widget/app.dart' deferred as app;
import 'package:example/src/common/widget/app_error.dart' deferred as app_error;
import 'package:example/src/feature/initialization/data/initialization.dart'
    deferred as initialization;
import 'package:example/src/feature/initialization/widget/inherited_dependencies.dart'
    deferred as inherited_dependencies;
import 'package:flutter/widgets.dart';
import 'package:l/l.dart';

void main() => l.capture<void>(
      () => runZonedGuarded<void>(
        () async {
          // Splash screen
          final initializationProgress =
              ValueNotifier<({int progress, String message})>(
                  (progress: 0, message: ''));
          /* runApp(SplashScreen(progress: initializationProgress)); */
          await initialization.loadLibrary();
          await inherited_dependencies.loadLibrary();
          await app.loadLibrary();
          initialization
              .$initializeApp(
                onProgress: (progress, message) => initializationProgress
                    .value = (progress: progress, message: message),
                onSuccess: (dependencies) => runApp(
                  inherited_dependencies.InheritedDependencies(
                    dependencies: dependencies,
                    child: app.App(),
                  ),
                ),
                onError: (error, stackTrace) async {
                  await app_error.loadLibrary();
                  runApp(app_error.AppError(error: error));
                  ErrorUtil.logError(error, stackTrace).ignore();
                },
              )
              .ignore();
        },
        l.e,
      ),
      const LogOptions(
        handlePrint: true,
        messageFormatting: _messageFormatting,
        outputInRelease: false,
        printColors: true,
      ),
    );

/// Formats the log message.
Object _messageFormatting(Object message, LogLevel logLevel, DateTime now) =>
    '${_timeFormat(now)} | $message';

/// Formats the time.
String _timeFormat(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
