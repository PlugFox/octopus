import 'package:example/src/common/controller/controller.dart';
import 'package:l/l.dart';

class ControllerObserver implements IControllerObserver {
  @override
  void onCreate(IController controller) {
    l.v6('Controller | ${controller.runtimeType} | Created');
  }

  @override
  void onDispose(IController controller) {
    l.v5('Controller | ${controller.runtimeType} | Disposed');
  }

  @override
  void onStateChanged(
      IController controller, Object prevState, Object nextState) {
    l.d('Controller | ${controller.runtimeType} | $prevState -> $nextState');
  }

  @override
  void onError(IController controller, Object error, StackTrace stackTrace) {
    l.w('Controller | ${controller.runtimeType} | $error', stackTrace);
  }
}
