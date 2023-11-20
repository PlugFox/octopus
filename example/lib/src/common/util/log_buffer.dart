import 'dart:collection' show Queue;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:l/l.dart';

/// LogBuffer Singleton class
class LogBuffer with ChangeNotifier {
  LogBuffer._internal();
  static final LogBuffer _internalSingleton = LogBuffer._internal();
  static LogBuffer get instance => _internalSingleton;

  static const int bufferLimit = 10000;
  final Queue<LogMessage> _queue = Queue<LogMessage>();

  /// Get the logs
  Iterable<LogMessage> get logs => _queue;

  /// Clear the logs
  void clear() {
    _queue.clear();
    notifyListeners();
  }

  /// Add a log to the buffer
  void add(LogMessage log) {
    if (_queue.length >= bufferLimit) _queue.removeFirst();
    _queue.add(log);
    notifyListeners();
  }

  /// Add a list of logs to the buffer
  void addAll(List<LogMessage> logs) {
    final list = logs.take(bufferLimit).toList();
    if (_queue.length + logs.length >= bufferLimit) {
      final toRemove = _queue.length + list.length - bufferLimit;
      for (var i = 0; i < toRemove; i++) _queue.removeFirst();
    }
    _queue.addAll(list);
    notifyListeners();
  }

  @override
  void dispose() {
    _queue.clear();
    super.dispose();
  }
}
