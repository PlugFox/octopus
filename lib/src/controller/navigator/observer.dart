import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/state/state.dart';

@internal
final class OctopusStateObserver$NavigatorImpl
    with ChangeNotifier
    implements OctopusStateObserver {
  OctopusStateObserver$NavigatorImpl(OctopusState$Immutable initialState,
      [List<OctopusHistoryEntry>? history])
      : _value = OctopusState$Immutable.from(initialState),
        _history = history?.toSet().toList() ?? <OctopusHistoryEntry>[] {
    // Add the initial state to the history.
    if (_history.isEmpty || _history.last.state != initialState) {
      _history.add(
        OctopusHistoryEntry(
          state: initialState,
          timestamp: DateTime.now(),
        ),
      );
    }
    _history.sort();
  }

  @protected
  @nonVirtual
  OctopusState$Immutable _value;

  @protected
  @nonVirtual
  final List<OctopusHistoryEntry> _history;

  @override
  List<OctopusHistoryEntry> get history =>
      UnmodifiableListView<OctopusHistoryEntry>(_history);

  @override
  void setHistory(Iterable<OctopusHistoryEntry> history) {
    _history
      ..clear()
      ..addAll(history)
      ..sort();
  }

  @override
  OctopusState$Immutable get value => _value;

  @internal
  bool changeState(OctopusState state) {
    if (state.children.isEmpty) return false;
    if (state.intention == OctopusStateIntention.cancel) return false;
    final newValue = OctopusState$Immutable.from(state);
    if (_value == newValue) return false;
    _value = newValue;
    late final historyEntry = OctopusHistoryEntry(
      state: newValue,
      timestamp: DateTime.now(),
    );
    switch (_value.intention) {
      case OctopusStateIntention.auto:
      case OctopusStateIntention.navigate:
      case OctopusStateIntention.replace when _history.isEmpty:
        _history.add(historyEntry);
      case OctopusStateIntention.replace:
        _history.last = historyEntry;
      case OctopusStateIntention.neglect:
      case OctopusStateIntention.cancel:
        break;
    }
    if (_history.length > OctopusStateObserver.maxHistoryLength)
      _history.removeAt(0);
    notifyListeners();
    return true;
  }
}
