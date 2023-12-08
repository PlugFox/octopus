// ignore_for_file: avoid_positional_boolean_parameters
//import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/*
 * Sentry.captureException(exception, stackTrace: stackTrace, hint: hint);
 * FirebaseCrashlytics.instance
 *   .recordError(exception, stackTrace ?? StackTrace.current, reason: hint, fatal: fatal);
 * */
Future<void> $captureException(
  Object exception,
  StackTrace stackTrace,
  String? hint,
  bool fatal,
) =>
    Future<void>.value();
// FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: hint, fatal: fatal);

/*
 * Sentry.captureMessage(
 *   message,
 *   level: warning ? SentryLevel.warning : SentryLevel.info,
 *   hint: hint,
 *   params: <String>[
 *     ...?params,
 *     if (stackTrace != null) 'StackTrace: $stackTrace',
 *   ],
 * );
 * (warning || stackTrace != null)
 *   ? FirebaseCrashlytics.instance.recordError(message, stackTrace ?? StackTrace.current);
 *   : FirebaseCrashlytics.instance.log('$message${hint != null ? '\r\n$hint' : ''}');
 * */
Future<void> $captureMessage(
  String message,
  StackTrace? stackTrace,
  String? hint,
  bool warning,
) =>
    Future<void>.value();
/* warning || stackTrace != null
        ? FirebaseCrashlytics.instance.recordError(
            message,
            stackTrace ?? StackTrace.current,
            reason: hint,
            fatal: false,
          )
        : FirebaseCrashlytics.instance.log('$message'
            '${stackTrace != null ? '\nHint: $hint' : ''}'); */
