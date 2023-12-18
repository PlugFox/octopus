import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Whether to enable logging.
@internal
const bool kLogEnabled =
    !kReleaseMode && bool.fromEnvironment('octopus.logs', defaultValue: false);

/// Whether to enable performance measurement.
@internal
const bool kMeasureEnabled =
    kLogEnabled && bool.fromEnvironment('octopus.measure', defaultValue: false);

/// Tracing information
@internal
final void Function(Object? message) fine = _logAll('FINE', 500);

/// Static configuration messages
@internal
final void Function(Object? message) config = _logAll('CONF', 700);

/// Iformational messages
@internal
final void Function(Object? message) info = _logAll('INFO', 800);

/// Potential problems
@internal
final void Function(Object exception, [StackTrace? stackTrace, String? reason])
    warning = _logAll('WARN', 900);

/// Serious failures
@internal
final void Function(Object error, [StackTrace stackTrace, String? reason])
    severe = _logAll('ERR!', 1000);

void Function(
  Object? message, [
  StackTrace? stackTrace,
  String? reason,
]) _logAll(String prefix, int level) => (message, [stackTrace, reason]) {
      if (!kLogEnabled) return;
      log(
        '${reason ?? message}',
        level: level,
        name: 'octopus',
        error: message is Exception || message is Error ? message : null,
        stackTrace: stackTrace,
      );
    };

/// Measure the execution time of the function.
@internal
Future<T> measureAsync<T>(
  String name,
  Future<T> Function() fn, {
  Map<String, String>? arguments,
}) async {
  if (!kMeasureEnabled) return fn();
  final stopwatch = Stopwatch()..start();
  Timeline.instantSync('$name#start', arguments: arguments);
  try {
    return await fn();
  } finally {
    Timeline.instantSync('$name#finish', arguments: arguments);
    stopwatch.stop();
    config('$name: ${stopwatch.elapsedMilliseconds} ms');
  }
}

/// Measure the execution time of the function.
@internal
T measureSync<T>(
  String name,
  T Function() fn, {
  Map<String, String>? arguments,
}) {
  if (!kMeasureEnabled) return fn();
  assert(fn is! Future, 'Use measureAsync instead.');
  final stopwatch = Stopwatch()..start();
  /* final flow = Flow.begin(); */
  Timeline.startSync(name, arguments: arguments /* , flow: flow */);
  try {
    return fn();
  } finally {
    Timeline.finishSync();
    stopwatch.stop();
    /* Flow.end(flow.id); */
    config('$name: ${stopwatch.elapsedMilliseconds} ms');
  }
}
