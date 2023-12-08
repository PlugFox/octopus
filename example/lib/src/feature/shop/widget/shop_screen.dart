import 'package:example/src/common/router/routes.dart';
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

  // Nested navigation cache
  static final Map<ShopTabsEnum, List<OctopusNode>> _nestedNavigation =
      <ShopTabsEnum, List<OctopusNode>>{};

  @override
  void initState() {
    super.initState();
    _octopus = Octopus.of(context);
    _octopusStateObserver = _octopus.stateObserver;

    // Restore tab from router arguments
    _tab = ShopTabsEnum.fromValue(
      _octopusStateObserver.value.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );

    final children = _octopusStateObserver.value
        .firstWhereOrNull((node) => node.name == Routes.shop.name)
        ?.children;
    if (children != null) {
      // If route contains nested children, cache them
      _nestedNavigation[_tab] = children;
    } else {
      // If route doesn't contain nested children, restore from cache
      _restoreTabState(_tab);
    }
    _octopusStateObserver.addListener(_onOctopusStateChanged);
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
      _octopus.state.arguments['shop'],
      fallback: ShopTabsEnum.catalog,
    );
    _backUpTabState(_tab);
    _switchTab(newTab);
  }

  // Backup tab state
  void _backUpTabState(ShopTabsEnum tab) {
    // Backup nested navigation
    _nestedNavigation[_tab] = _octopusStateObserver.value
            .firstWhereOrNull((node) => node.name == Routes.shop.name)
            ?.children ??
        const <OctopusNode>[];
  }

  // Restore tab state
  void _restoreTabState(ShopTabsEnum tab) {
    // Restore nested navigation
    _octopus.setState((state) {
      // Set new tab argument
      state.arguments['shop'] = tab.value;
      // Find shop node and update children from cache
      state.firstWhereOrNull((node) => node.name == Routes.shop.name)?.children
        ?..clear()
        ..addAll(_nestedNavigation[tab] ?? const <OctopusNode>[]);
      return state;
    });
  }

  // Change tab
  void _switchTab(ShopTabsEnum tab) {
    if (!mounted) return;
    if (_tab == tab) return;
    _restoreTabState(tab);
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: switch (_tab) {
          ShopTabsEnum.catalog => const CatalogTab(),
          ShopTabsEnum.basket => const BasketTab(),
          ShopTabsEnum.favorites => const FavoritesTab(),
        },
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
