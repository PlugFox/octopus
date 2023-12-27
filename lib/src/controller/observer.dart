import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';

/// Octopus state observer.
abstract interface class OctopusStateObserver
    implements ValueListenable<OctopusState$Immutable> {
  /// Max history length.
  static const int maxHistoryLength = 10000;

  /// Current immutable state.
  @override
  OctopusState$Immutable get value;

  /// History of the states.
  List<OctopusHistoryEntry> get history;

  /// Set history.
  void setHistory(Iterable<OctopusHistoryEntry> history);
}

/// {@template history_entry}
/// Octopus history entry.
/// {@endtemplate}
@immutable
final class OctopusHistoryEntry implements Comparable<OctopusHistoryEntry> {
  /// {@macro history_entry}
  OctopusHistoryEntry({
    required this.state,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create an entry from json.
  ///
  /// {@macro history_entry}
  factory OctopusHistoryEntry.fromJson(Map<String, Object?> json) {
    if (json
        case <String, Object?>{
          'timestamp': String timestamp,
          'state': Map<String, Object?> state,
        }) {
      return OctopusHistoryEntry(
        state: OctopusState.fromJson(state).freeze(),
        timestamp: DateTime.parse(timestamp),
      );
    } else {
      throw const FormatException('Invalid json');
    }
  }

  /// The state of the entry.
  final OctopusState$Immutable state;

  /// The timestamp of the entry.
  final DateTime timestamp;

  @override
  int compareTo(covariant OctopusHistoryEntry other) =>
      timestamp.compareTo(other.timestamp);

  /// Convert the entry to json.
  Map<String, Object?> toJson() => <String, Object?>{
        'timestamp': timestamp.toIso8601String(),
        'state': state.toJson(),
      };

  @override
  late final int hashCode = state.hashCode ^ timestamp.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctopusHistoryEntry &&
          timestamp == other.timestamp &&
          state == other.state;
}
