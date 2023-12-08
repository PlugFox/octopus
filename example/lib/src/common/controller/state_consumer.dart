import 'package:example/src/common/controller/state_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Fire when the state changes.
typedef StateConsumerListener<S> = void Function(
    BuildContext context, S previous, S current);

/// Build when the method returns true.
typedef StateConsumerCondition<S> = bool Function(S previous, S current);

/// Rebuild the widget when the state changes.
typedef StateConsumerBuilder<S> = Widget Function(
    BuildContext context, S state, Widget? child);

/// {@template state_consumer}
/// StateBuilder widget.
/// {@endtemplate}
class StateConsumer<S extends Object> extends StatefulWidget {
  /// {@macro state_builder}
  const StateConsumer({
    required this.controller,
    this.listener,
    this.buildWhen,
    this.builder,
    this.child,
    super.key,
  });

  /// The controller responsible for processing the logic,
  final IStateController<S> controller;

  /// Takes the `BuildContext` along with the `state`
  /// and is responsible for executing in response to `state` changes.
  final StateConsumerListener<S>? listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final StateConsumerCondition<S>? buildWhen;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final StateConsumerBuilder<S>? builder;

  /// The child widget which will be passed to the [builder].
  final Widget? child;

  @override
  State<StateConsumer<S>> createState() => _StateConsumerState<S>();
}

class _StateConsumerState<S extends Object> extends State<StateConsumer<S>> {
  late IStateController<S> _controller;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _previousState = _controller.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(StateConsumer<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller,
        newController = widget.controller;
    if (identical(oldController, newController) ||
        oldController == newController) return;
    _unsubscribe();
    _controller = newController;
    _previousState = newController.state;
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() => _controller.addListener(_valueChanged);

  void _unsubscribe() => _controller.removeListener(_valueChanged);

  void _valueChanged() {
    final oldState = _previousState, newState = _controller.state;
    if (!mounted || identical(oldState, newState)) return;
    _previousState = newState;
    widget.listener?.call(context, oldState, newState);
    if (widget.buildWhen?.call(oldState, newState) ?? true) {
      // Rebuild the widget when the state changes.
      switch (SchedulerBinding.instance.schedulerPhase) {
        case SchedulerPhase.idle:
        case SchedulerPhase.transientCallbacks:
        case SchedulerPhase.postFrameCallbacks:
          setState(() {});
        case SchedulerPhase.persistentCallbacks:
        case SchedulerPhase.midFrameMicrotasks:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {});
          });
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) =>
      super.debugFillProperties(properties
        ..add(
            DiagnosticsProperty<IStateController<S>>('Controller', _controller))
        ..add(DiagnosticsProperty<S>('State', _controller.state))
        ..add(FlagProperty('isProcessing',
            value: _controller.isProcessing,
            ifTrue: 'Processing',
            ifFalse: 'Idle')));

  @override
  Widget build(BuildContext context) =>
      widget.builder?.call(context, _controller.state, widget.child) ??
      widget.child ??
      const SizedBox.shrink();
}
