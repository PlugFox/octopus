import 'dart:async';
import 'dart:convert';

import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/shop/widget/basket_screen.dart';
import 'package:example/src/feature/shop/widget/catalog_screen.dart';
import 'package:example/src/feature/shop/widget/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template shop_tabs_enum}
/// ShopTabsEnum enumeration
/// {@endtemplate}
enum ShopTabsEnum implements Comparable<ShopTabsEnum> {
  /// Catalog
  catalog('catalog'),

  /// Basket
  basket('basket'),

  /// Favorites
  favorites('favorites');

  /// {@macro shop_tabs_enum}
  const ShopTabsEnum(this.value);

  /// Creates a new instance of [ShopTabsEnum] from a given string.
  static ShopTabsEnum fromValue(String? value, {ShopTabsEnum? fallback}) =>
      switch (value?.trim().toLowerCase()) {
        'catalog' => catalog,
        'basket' => basket,
        'favorites' => favorites,
        _ => fallback ?? (throw ArgumentError.value(value)),
      };

  /// Value of the enum
  final String value;

  /// Pattern matching
  T map<T>({
    required T Function() catalog,
    required T Function() basket,
    required T Function() favorites,
  }) =>
      switch (this) {
        ShopTabsEnum.catalog => catalog(),
        ShopTabsEnum.basket => basket(),
        ShopTabsEnum.favorites => favorites(),
      };

  /// Pattern matching
  T maybeMap<T>({
    required T Function() orElse,
    T Function()? catalog,
    T Function()? basket,
    T Function()? favorites,
  }) =>
      map<T>(
        catalog: catalog ?? orElse,
        basket: basket ?? orElse,
        favorites: favorites ?? orElse,
      );

  /// Pattern matching
  T? maybeMapOrNull<T>({
    T Function()? catalog,
    T Function()? basket,
    T Function()? favorites,
  }) =>
      maybeMap<T?>(
        orElse: () => null,
        catalog: catalog,
        basket: basket,
        favorites: favorites,
      );

  @override
  int compareTo(ShopTabsEnum other) => index.compareTo(other.index);

  @override
  String toString() => value;
}

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
  Future<OctopusState?> restore(OctopusState state) async {
    try {
      final node = state.find((node) => node.name == Routes.shop.name);
      // Do not restore, if nested state is not empty
      if (node != null && node.children.isNotEmpty) return null;
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
    }
    return null;
  }

  Future<void> clear() => _prefs.remove(_key);
}

/// {@template shop_screen}
/// ShopScreen widget.
/// {@endtemplate}
class ShopScreen extends StatefulWidget {
  /// {@macro shop_screen}
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopTabsEnum _tab = ShopTabsEnum.catalog;
  late final OctopusStateObserver _octopusStateObserver;

  // Nested navigation cache
  late final ShopTabsCacheService _cache;

  @override
  void initState() {
    super.initState();
    final octopus = Octopus.of(context);
    _octopusStateObserver = octopus.stateObserver;
    _cache = ShopTabsCacheService(
      sharedPreferences: Dependencies.of(context).sharedPreferences,
    );

    // Restore tab from router arguments
    _tab = ShopTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );
    _octopusStateObserver.addListener(_onOctopusStateChanged);

    // Restore nested navigation from cache and merge with current state
    _cache.restore(_octopusStateObserver.value).then((newState) {
      if (newState != null)
        octopus.setState((state) {
          final newShop =
              newState.find((node) => node.name == Routes.shop.name);
          if (newShop == null) return state;
          state.replaceWhere(newShop, (node) => node.name == Routes.shop.name);
          return state;
        });
    }).ignore();
  }

  @override
  void dispose() {
    _octopusStateObserver.removeListener(_onOctopusStateChanged);
    super.dispose();
  }

  // Bottom navigation bar item tapped
  void _onItemTapped(int index) {
    final newTab = ShopTabsEnum.values[index];
    _switchTab(newTab);
  }

  // Router state changed
  void _onOctopusStateChanged() {
    final newTab = ShopTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );
    _switchTab(newTab);
    _cache.save(_octopusStateObserver.value).ignore();
  }

  // Change tab
  void _switchTab(ShopTabsEnum tab) {
    if (!mounted) return;
    if (_tab == tab) return;
    Octopus.of(context).setState(
      (state) => state..arguments['shop'] = tab.value,
    );
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // Disable page transition animation
        body: NoAnimationScope(
          child: IndexedStack(
            index: _tab.index,
            children: const <Widget>[
              CatalogTab(),
              BasketTab(),
              FavoritesTab(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'Catalog',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Basket',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
              backgroundColor: Colors.pink,
            ),
          ],
          currentIndex: _tab.index,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
}
