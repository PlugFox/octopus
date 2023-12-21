import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';

/// {@nodoc}
@internal
class OctopusStateQueue implements Sink<OctopusState> {
  /// {@nodoc}
  OctopusStateQueue(
      {required Future<void> Function(OctopusState state) processor,
      String debugLabel = 'OctopusStateQueue'})
      : _stateProcessor = processor,
        _debugLabel = debugLabel;

  final DoubleLinkedQueue<_StateTask> _queue = DoubleLinkedQueue<_StateTask>();
  final Future<void> Function(OctopusState state) _stateProcessor;
  final String _debugLabel;
  Future<void>? _processing;

  /// Completes when the queue is empty.
  /// {@nodoc}
  Future<void> get processingCompleted => _processing ?? Future<void>.value();

  /// Notify when processing completed
  /// {@nodoc}
  final ChangeNotifier _processingCompleteNotifier = ChangeNotifier();

  /// Add complete listener
  /// {@nodoc}
  void addCompleteListener(VoidCallback listener) =>
      _processingCompleteNotifier.addListener(listener);

  /// Remove complete listener
  /// {@nodoc}
  void removeCompleteListener(VoidCallback listener) =>
      _processingCompleteNotifier.removeListener(listener);

  /// Whether the queue is currently processing a task.
  /// {@nodoc}
  bool get isProcessing => _processing != null;

  /// Whether the queue is closed.
  /// {@nodoc}
  bool get isClosed => _closed;
  bool _closed = false;

  @override
  Future<void> add(OctopusState state) {
    if (_closed) throw StateError('OctopusStateQueue is closed');
    final task = _StateTask(state);
    _queue.add(task);
    _start();
    developer.Timeline.instantSync('$_debugLabel:add');
    return task.future;
  }

  @override
  Future<void> close({bool force = false}) async {
    _closed = true;
    if (force) {
      for (final task in _queue) {
        task.reject(
          StateError('OctopusStateQueue is closed'),
          StackTrace.current,
        );
      }
      _queue.clear();
    } else {
      await _processing;
    }
    scheduleMicrotask(_processingCompleteNotifier.dispose);
  }

  Future<void> _start() {
    final processing = _processing;
    if (processing != null) return processing;
    final flow = developer.Flow.begin();
    developer.Timeline.instantSync('$_debugLabel:begin');
    return _processing = Future.doWhile(() async {
      if (_queue.isEmpty) {
        _processing = null;
        developer.Timeline.instantSync('$_debugLabel:end');
        developer.Flow.end(flow.id);
        return false;
      }
      try {
        await developer.Timeline.timeSync(
          '$_debugLabel:task',
          () => _queue.removeFirst()(_stateProcessor),
          flow: developer.Flow.step(flow.id),
        );
      } on Object catch (error, stackTrace) {
        developer.log(
          'Failed to process state',
          name: 'octopus',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return true;
    });
  }
}

@immutable
class _StateTask {
  _StateTask(OctopusState state)
      : _state = state,
        _completer = Completer<void>.sync();

  final OctopusState _state;
  final Completer<void> _completer;

  /// {@nodoc}
  Future<void> get future => _completer.future;

  /// {@nodoc}
  Future<void> call(Future<void> Function(OctopusState) fn) async {
    try {
      if (_completer.isCompleted) return;
      await fn(_state);
      if (_completer.isCompleted) return;
      _completer.complete();
    } on Object catch (error, stackTrace) {
      _completer.completeError(error, stackTrace);
    }
  }

  /// {@nodoc}
  void reject(Object error, [StackTrace? stackTrace]) {
    if (_completer.isCompleted) return; // coverage:ignore-line
    _completer.completeError(error, stackTrace);
  }
}
