import 'dart:async';
import 'dart:collection';

import 'package:example/src/common/controller/controller.dart';
import 'package:meta/meta.dart';

base mixin SequentialControllerConcurrency on Controller {
  final _ControllerEventQueue _eventQueue = _ControllerEventQueue();

  @override
  @nonVirtual
  bool get isProcessing => _eventQueue.length > 0;

  @override
  @protected
  @mustCallSuper
  void handle(
    FutureOr<void> Function() handler, [
    FutureOr<void> Function(Object error, StackTrace stackTrace)? errorHandler,
    FutureOr<void> Function()? doneHandler,
  ]) =>
      _eventQueue.push<void>(
        () {
          final completer = Completer<void>();
          runZonedGuarded<void>(
            () async {
              if (isDisposed) return;
              try {
                await handler();
              } on Object catch (error, stackTrace) {
                onError(error, stackTrace);
                await Future<void>(() async {
                  await errorHandler?.call(error, stackTrace);
                }).catchError(onError);
              } finally {
                await Future<void>(() async {
                  await doneHandler?.call();
                }).catchError(onError);
                completer.complete();
              }
            },
            onError,
          );
          return completer.future;
        },
      );
}

final class _ControllerEventQueue {
  _ControllerEventQueue();

  final DoubleLinkedQueue<_SequentialTask<Object?>> _queue =
      DoubleLinkedQueue<_SequentialTask<Object?>>();
  Future<void>? _processing;
  bool _isClosed = false;

  /// Event queue length.
  int get length => _queue.length;

  /// Push it at the end of the queue.
  Future<T> push<T>(FutureOr<T> Function() fn) {
    final task = _SequentialTask<T>(fn);
    _queue.add(task);
    _exec();
    return task.future;
  }

  /// Mark the queue as closed.
  /// The queue will be processed until it's empty.
  /// But all new and current events will be rejected with [WSClientClosed].
  FutureOr<void> close() async {
    _isClosed = true;
    await _processing;
  }

  /// Execute the queue.
  void _exec() => _processing ??= Future.doWhile(() async {
        final event = _queue.first;
        try {
          if (_isClosed) {
            event.reject(StateError('Controller\'s event queue are disposed'),
                StackTrace.current);
          } else {
            await event();
          }
        } on Object catch (error, stackTrace) {
          /* warning(
            error,
            stackTrace,
            'Error while processing event "${event.id}"',
          ); */
          Future<void>.sync(() => event.reject(error, stackTrace)).ignore();
        }
        _queue.removeFirst();
        final isEmpty = _queue.isEmpty;
        if (isEmpty) _processing = null;
        return !isEmpty;
      });
}

class _SequentialTask<T> {
  _SequentialTask(FutureOr<T> Function() fn)
      : _fn = fn,
        _completer = Completer<T>();

  final Completer<T> _completer;

  final FutureOr<T> Function() _fn;

  Future<T> get future => _completer.future;

  FutureOr<T> call() async {
    final result = await _fn();
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
    return result;
  }

  void reject(Object error, [StackTrace? stackTrace]) {
    if (_completer.isCompleted) return;
    _completer.completeError(error, stackTrace);
  }
}
