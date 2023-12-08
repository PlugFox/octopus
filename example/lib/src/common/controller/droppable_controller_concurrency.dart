import 'dart:async';

import 'package:example/src/common/controller/controller.dart';
import 'package:meta/meta.dart';

base mixin DroppableControllerConcurrency on Controller {
  @override
  @nonVirtual
  bool get isProcessing => _$processingCalls > 0;
  int _$processingCalls = 0;

  @override
  @protected
  @mustCallSuper
  void handle(
    FutureOr<void> Function() handler, [
    FutureOr<void> Function(Object error, StackTrace stackTrace)? errorHandler,
    FutureOr<void> Function()? doneHandler,
  ]) =>
      runZonedGuarded<void>(
        () async {
          if (isDisposed || isProcessing) return;
          _$processingCalls++;
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
            _$processingCalls--;
          }
        },
        onError,
      );
}
