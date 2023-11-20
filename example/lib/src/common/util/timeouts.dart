import 'dart:async';

/// Extension methods for [Future].
extension TimeoutsExtension<T extends Object?> on Future<T> {
  /// Returns a [Future] that completes with this future's result, or with the
  /// result of calling the [onTimeout] function, if this future doesn't
  /// complete before the timeout is exceeded.
  ///
  /// The [onTimeout] function must return a [Future] which will be used as the
  /// result of the returned [Future], and must not throw.
  Future<T> logicTimeout({
    double coefficient = 1,
    FutureOr<T> Function()? onTimeout,
  }) =>
      timeout(
        const Duration(milliseconds: 20000) * coefficient,
        onTimeout: onTimeout,
      );
}
