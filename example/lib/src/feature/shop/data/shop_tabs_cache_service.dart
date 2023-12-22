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
      final tab = state.arguments['shop'];
      final node = state.find((node) => node.name == Routes.shop.name);
      if (node == null) return; // Save only with existing nested navigation
      final json = <String, Object?>{
        'tab': tab,
        'node': node.toJson(),
      };
      await _prefs.setString(_key, jsonEncode(json));
    } on Object {/* ignore */}
  }

  /// Restore nested navigation from cache
  Future<OctopusState$Mutable?> restore(OctopusState state) async {
    /* try {
      var shop = state.findByName(Routes.shop.name);
      // Do not restore, if nested state is not empty
      if (shop == null) {
        shop.add(OctopusNode.mutable(Routes.catalog.name));
      }
      final jsonRaw = _prefs.getString(_key);
      if (jsonRaw == null) return null;
      final json = jsonDecode(jsonRaw);
      if (json case Map<String, Object?> data) {
        final newState = state.mutate();
        if (data['tab'] case String tab) newState.arguments['shop'] = tab;
        if (data['node'] case Map<String, Object?> node) {
          final newNode = OctopusNode.fromJson(node);
          newState.children
            ..removeWhere((n) => n.name == Routes.shop.name)
            ..add(newNode);
        }
        return newState;
      }
    } on Object {
      /* ignore */
    } */
    return null;
  }

  Future<void> clear() => _prefs.remove(_key);
}
