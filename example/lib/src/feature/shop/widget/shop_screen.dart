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
  const ShopTabsEnum(this.name);

  /// Creates a new instance of [ShopTabsEnum] from a given string.
  static ShopTabsEnum fromValue(String? value, {ShopTabsEnum? fallback}) =>
      switch (value?.trim().toLowerCase()) {
        'catalog' => catalog,
        'basket' => basket,
        'favorites' => favorites,
        _ => fallback ?? (throw ArgumentError.value(value)),
      };

  /// Value of the enum
  final String name;

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
  String toString() => name;
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
  // Octopus state observer
  late final OctopusStateObserver _octopusStateObserver;

  // Current tab
  ShopTabsEnum _tab = ShopTabsEnum.catalog;

  @override
  void initState() {
    super.initState();
    _octopusStateObserver = Octopus.of(context).stateObserver;

    // Restore tab from router arguments
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

  // Change tab
  void _switchTab(ShopTabsEnum tab) {
    if (!mounted) return;
    if (_tab == tab) return;
    Octopus.of(context).setArguments((args) => args['shop'] = tab.name);
    setState(() => _tab = tab);
  }

  // Pop to catalog at double tap on catalog tab
  void _clearCatalogNavigationStack() {
    Octopus.of(context).setState((state) {
      final catalog = state.findByName('catalog-tab');
      if (catalog == null || catalog.children.length < 2) return state;
      catalog.children.length = 1;
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Poped to catalog tab at double tap'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return state;
    });
  }

  // Bottom navigation bar item tapped
  void _onItemTapped(int index) {
    final newTab = ShopTabsEnum.values[index];
    if (_tab == newTab) {
      // The same tab tapped twice
      if (newTab == ShopTabsEnum.catalog) _clearCatalogNavigationStack();
    } else {
      // Switch tab to new one
      _switchTab(newTab);
    }
  }

  // Router state changed
  void _onOctopusStateChanged() {
    final newTab = ShopTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );
    _switchTab(newTab);
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
