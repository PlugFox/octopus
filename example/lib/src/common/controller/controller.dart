import 'dart:async';

import 'package:flutter/foundation.dart' show Listenable, ChangeNotifier;
import 'package:meta/meta.dart';

/// {@template controller}
/// The controller responsible for processing the logic,
/// the connection of widgets and the date of the layer.
/// {@endtemplate}
abstract interface class IController implements Listenable {
  /// Whether the controller is currently handling a requests
  bool get isProcessing;

  /// Discards any resources used by the object.
  ///
  /// This method should only be called by the object's owner.
  void dispose();
}

/// Controller observer
abstract interface class IControllerObserver {
  /// Called when the controller is created.
  void onCreate(IController controller);

  /// Called when the controller is disposed.
  void onDispose(IController controller);

  /// Called on any state change in the controller.
  void onStateChanged(
      IController controller, Object prevState, Object nextState);

  /// Called on any error in the controller.
  void onError(IController controller, Object error, StackTrace stackTrace);
}

/// {@template controller}
/// The controller responsible for processing the logic,
/// the connection of widgets and the date of the layer.
/// {@endtemplate}
abstract base class Controller with ChangeNotifier implements IController {
  Controller() {
    runZonedGuarded<void>(
      () => Controller.observer?.onCreate(this),
      (error, stackTrace) {/* ignore */},
    );
  }

  /// Controller observer
  static IControllerObserver? observer;

  bool get isDisposed => _$isDisposed;
  bool _$isDisposed = false;

  @protected
  void onError(Object error, StackTrace stackTrace) => runZonedGuarded<void>(
        () => Controller.observer?.onError(this, error, stackTrace),
        (error, stackTrace) {/* ignore */},
      );

  @protected
  void handle(FutureOr<void> Function() handler);

  @override
  @mustCallSuper
  void dispose() {
    _$isDisposed = true;
    runZonedGuarded<void>(
      () => Controller.observer?.onDispose(this),
      (error, stackTrace) {/* ignore */},
    );
    super.dispose();
  }

  @protected
  @nonVirtual
  @override
  void notifyListeners() => super.notifyListeners();
}
