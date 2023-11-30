import 'package:example/src/feature/shop/widget/basket_screen.dart';
import 'package:example/src/feature/shop/widget/catalog_screen.dart';
import 'package:example/src/feature/shop/widget/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

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
  late final Octopus _octopus;
  late final OctopusStateObserver _octopusStateObserver;

  @override
  void initState() {
    super.initState();
    _octopus = Octopus.of(context);
    _octopusStateObserver = _octopus.stateObserver;
    _tab = ShopTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );
    _octopusStateObserver.addListener(_onOctopusStateChanged);
  }

  @override
  void dispose() {
    _octopusStateObserver.removeListener(_onOctopusStateChanged);
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    final newTab = ShopTabsEnum.values[index];
    _octopus.setState((state) => state..arguments['shop'] = newTab.value);
    setState(() => _tab = newTab);
  }

  void _onOctopusStateChanged() {
    if (!mounted) return;
    final newTab = ShopTabsEnum.fromValue(
      _octopus.state.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );
    if (_tab == newTab) return;
    setState(() => _tab = newTab);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        /* appBar: AppBar(
          title: Text(
            _tab.map<String>(
              catalog: () => 'Catalog',
              basket: () => 'Basket',
              favorites: () => 'Favorites',
            ),
            key: ValueKey(_tab.index),
          ),
        ), */
        body: switch (_tab) {
          ShopTabsEnum.catalog => const CatalogScreen(),
          ShopTabsEnum.basket => const BasketScreen(),
          ShopTabsEnum.favorites => const FavoritesScreen(),
        },
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Basket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
          currentIndex: _tab.index,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
}
