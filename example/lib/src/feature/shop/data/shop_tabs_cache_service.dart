import 'dart:convert';

import 'package:example/src/common/router/routes.dart';
import 'package:octopus/octopus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Restore cached nested navigation on tab switch
class ShopTabsCacheService {
  ShopTabsCacheService({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  static const String _key = 'shop.tabs';

  final SharedPreferences _prefs;

  /// Save nested navigation to cache
  Future<void> save(OctopusState state) async {
    try {
      final argument = state.arguments['shop'];
      final shop = state.findByName(Routes.shop.name);
      if (shop == null) return;
      final catalog = shop.findByName('catalog-tab');
      final basket = shop.findByName('basket-tab');
      final json = <String, Object?>{
        if (argument != null) 'tab': argument,
        if (catalog != null) 'catalog': catalog.toJson(),
        if (basket != null) 'basket': basket.toJson(),
      };
      if (json.isEmpty) return;
      await _prefs.setString(_key, jsonEncode(json));
    } on Object {/* ignore */}
  }

  /// Restore nested navigation from cache
  Future<OctopusState$Mutable?> restore(OctopusState$Mutable state) async {
    final shop = state.findByName(Routes.shop.name);
    if (shop == null) return null; // Do nothing if `shop` not found.
    try {
      final jsonRaw = _prefs.getString(_key);
      if (jsonRaw == null) return null;
      final json = jsonDecode(jsonRaw);
      if (json case Map<String, Object?> data) {
        if (data['tab'] case String tab) state.arguments['shop'] = tab;
        if (data['catalog'] case Map<String, Object?> catalog)
          shop.putIfAbsent('catalog-tab', () => OctopusNode.fromJson(catalog));
        if (data['basket'] case Map<String, Object?> basket)
          shop.putIfAbsent('basket-tab', () => OctopusNode.fromJson(basket));
        return state;
      }
    } on Object {/* ignore */}
    return null;
  }

  Future<void> clear() => _prefs.remove(_key);
}
