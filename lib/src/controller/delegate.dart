import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/octopus.dart';
import 'package:octopus/src/state/state.dart';

/// Octopus delegate.
/// {@nodoc}
@internal
final class OctopusDelegate extends RouterDelegate<OctopusState>
    with ChangeNotifier, _OctopusStateObserver {
  /// Octopus delegate.
  /// {@nodoc}
  OctopusDelegate({
    required OctopusState initialState,
    String? restorationScopeId = 'octopus',
    List<NavigatorObserver>? observers,
    TransitionDelegate<Object?>? transitionDelegate,
    RouteFactory? notFound,
    void Function(Object error, StackTrace stackTrace)? onError,
  })  : _restorationScopeId = restorationScopeId,
        _observers = observers,
        _transitionDelegate =
            transitionDelegate ?? const DefaultTransitionDelegate<Object?>(),
        _notFound = notFound,
        _onError = onError {
    _value = initialState;
  }

  /// The restoration scope id for the navigator.
  final String? _restorationScopeId;

  /// Observers for the navigator.
  final List<NavigatorObserver>? _observers;

  /// Transition delegate.
  final TransitionDelegate<Object?> _transitionDelegate;

  /// Not found route.
  final RouteFactory? _notFound;

  /// Error handler.
  final void Function(Object error, StackTrace stackTrace)? _onError;

  /// Current octopus instance.
  late Octopus _controller;

  @internal
  set $controller(Octopus controller) => _controller = controller;

  T _handleErrors<T>(
    T Function() callback, [
    T Function(Object error, StackTrace stackTrace)? fallback,
  ]) {
    try {
      return callback();
    } on Object catch (e, s) {
      _onError?.call(e, s);
      if (fallback == null) rethrow;
      return fallback(e, s);
    }
  }

  /// Current configuration.
  @override
  OctopusState get currentConfiguration =>
      // ignore: prefer_expression_function_bodies
      _handleErrors(() {
        return value;
      });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  Future<bool> popRoute() {
    // TODO: implement popRoute
    throw UnimplementedError();
  }

  @override
  Future<void> setNewRoutePath(OctopusState configuration) {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }
}

mixin _OctopusStateObserver
    on RouterDelegate<OctopusState>, ChangeNotifier
    implements ValueListenable<OctopusState> {
  @protected
  @nonVirtual
  late OctopusState _value;

  @override
  OctopusState get value => _value;

  @protected
  @nonVirtual
  void changeState(OctopusState? state) {
    if (state == null) return;
    _value = state;
    notifyListeners();
  }
}
