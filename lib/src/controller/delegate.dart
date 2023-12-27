import 'package:flutter/widgets.dart';
import 'package:octopus/src/state/state.dart';

/// Octopus delegate.
abstract base class OctopusDelegate extends RouterDelegate<OctopusState> {
  /// Routes hash table.
  abstract final Map<String, OctopusRoute> routes;

  /// Whether the controller is currently processing a tasks.
  bool get isProcessing;

  /// Completes when processing queue is empty
  /// and all transactions are completed.
  /// This is mean controller is ready to use and in a idle state.
  Future<void> get processingCompleted;

  /// Build pages from [OctopusNode]s.
  List<Page<Object?>> buildPages(BuildContext context, List<OctopusNode> nodes);
}
