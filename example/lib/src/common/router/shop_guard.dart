import 'dart:async';

import 'package:example/src/common/router/routes.dart';
import 'package:octopus/octopus.dart';

/// Do not allow any nested routes at `shop` inderectly except of `*-tab`.
class ShopGuard extends OctopusGuard {
  ShopGuard();

  @override
  FutureOr<OctopusState?> call(
    List<OctopusHistoryEntry> history,
    OctopusState state,
    Map<String, Object?> context,
  ) =>
      state
        ..find((node) => node.name == Routes.shop.name)
            ?.children
            .removeWhere((node) => !node.name.endsWith('-tab'));
}
