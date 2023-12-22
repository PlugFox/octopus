import 'dart:async';

import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/shop/data/shop_tabs_cache_service.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:octopus/octopus.dart';

/// Do not allow any nested routes at `shop` inderectly except of `*-tab`.
class ShopGuard extends OctopusGuard {
  ShopGuard({
    ShopTabsCacheService? cache,
  }) : _cache = cache;

  final ShopTabsCacheService? _cache;

  static final String _catalogTab = '${ShopTabsEnum.catalog.name}-tab';
  static final String _basketTab = '${ShopTabsEnum.basket.name}-tab';

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) {
    final shop = state.findByName(Routes.shop.name);
    if (shop == null) return state; // Do nothing if `shop` not found.

    /* // Restore state from cache if exists.
    if (!shop.hasChildren) {
      _cache?.restore(state);
    } */

    // Remove all nested routes except of `*-tab`.
    shop.removeWhere(
      (node) => node.name != _catalogTab && node.name != _basketTab,
      recursive: false,
    );
    // Upsert catalog tab node if not exists.
    final catalog =
        shop.putIfAbsent(_catalogTab, () => OctopusNode.mutable(_catalogTab));
    if (!catalog.hasChildren)
      catalog.add(OctopusNode.mutable(Routes.catalog.name));
    // Upsert basket tab node if not exists.
    final basket =
        shop.putIfAbsent(_basketTab, () => OctopusNode.mutable(_basketTab));
    if (!basket.hasChildren)
      basket.add(OctopusNode.mutable(Routes.basket.name));

    // Update cache.
    _cache?.save(state);
    return state;
  }
}
