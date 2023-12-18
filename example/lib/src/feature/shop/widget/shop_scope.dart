import 'dart:collection';

import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/feature/shop/controller/favorite_controller.dart';
import 'package:example/src/feature/shop/controller/shop_controller.dart';
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// {@template shop_scope}
/// ShopScope widget.
/// {@endtemplate}
class ShopScope extends StatefulWidget {
  /// {@macro shop_scope}
  const ShopScope({
    required this.child,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Refetch data.
  static void refetch(BuildContext context) =>
      Dependencies.of(context).shopController.fetch();

  /// Get list of root categories.
  static List<CategoryEntity> getRootCategories(
    BuildContext context, {
    bool listen = true,
  }) =>
      _InheritedCategories.getRootCategories(context, listen: listen);

  /// Get category content by id.
  static CategoryContent? getCategoryById(
    BuildContext context,
    CategoryID id, {
    bool listen = true,
  }) =>
      _InheritedCategories.getById(context, id, listen: listen);

  /// Get product by id.
  static ProductEntity? getProductById(
    BuildContext context,
    ProductID id, {
    bool listen = true,
  }) =>
      _InheritedProducts.getById(context, id, listen: listen);

  /// Get list of favorite products.
  static Set<ProductID> getFavorites(
    BuildContext context, {
    bool listen = true,
  }) =>
      _InheritedFavorite.getFavorites(context, listen: listen);

  /// Check if the product is in the favorite list.
  static bool isFavorite(
    BuildContext context,
    ProductID id, {
    bool listen = true,
  }) =>
      _InheritedFavorite.isFavorite(context, id, listen: listen);

  /// Add a product to the favorite list.
  static void addFavorite(
    BuildContext context,
    ProductID id,
  ) =>
      Dependencies.of(context).favoriteController.add(id);

  /// Remove a product from the favorite list.
  static void removeFavorite(
    BuildContext context,
    ProductID id,
  ) =>
      Dependencies.of(context).favoriteController.remove(id);

  @override
  State<ShopScope> createState() => _ShopScopeState();
}

/// State for widget ShopScope.
class _ShopScopeState extends State<ShopScope> {
  late final ShopController _shopController;
  late final FavoriteController _favoriteController;
  List<CategoryEntity> _categories = <CategoryEntity>[];
  List<ProductEntity> _products = <ProductEntity>[];
  List<CategoryEntity> _rootCategories = <CategoryEntity>[];
  Map<CategoryID, CategoryContent> _tableCategories =
      <CategoryID, CategoryContent>{};
  Map<ProductID, ProductEntity> _tableProduct = <ProductID, ProductEntity>{};
  Set<ProductID> _favorites = <ProductID>{};

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _shopController = Dependencies.of(context).shopController;
    _favoriteController = Dependencies.of(context).favoriteController;
    _favoriteController.addListener(_onFavoriteChanged);
    _shopController.addListener(_onStateChanged);
    _onStateChanged();
  }

  @override
  void dispose() {
    _shopController.removeListener(_onStateChanged);
    _favoriteController.removeListener(_onFavoriteChanged);
    super.dispose();
  }
  /* #endregion */

  void _onStateChanged() {
    if (!mounted) return;
    if (identical(_categories, _shopController.state.categories)) return;
    if (identical(_products, _shopController.state.products)) return;
    _categories = _shopController.state.categories;
    _products = _shopController.state.products;
    _rootCategories = <CategoryEntity>[];
    _tableCategories = <CategoryID, CategoryContent>{};
    _tableProduct = <ProductID, ProductEntity>{};
    for (final category in _shopController.state.categories) {
      if (category.isRoot) _rootCategories.add(category);
      _tableCategories[category.id] = CategoryContent._(category);
    }
    for (final product in _shopController.state.products) {
      _tableProduct[product.id] = product;
      _tableCategories[product.category]?._products.add(product);
    }
    for (final category in _shopController.state.categories) {
      if (category.isRoot) continue;
      _tableCategories[category.parent]?._categories.add(category);
    }
    setState(() {});
  }

  void _onFavoriteChanged() {
    if (!mounted) return;
    if (identical(_favorites, _favoriteController.state.products)) return;
    _favorites = _favoriteController.state.products;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _InheritedCategories(
        root: _rootCategories,
        table: _tableCategories,
        child: _InheritedProducts(
          table: _tableProduct,
          child: _InheritedFavorite(
            favorites: _favorites,
            child: widget.child,
          ),
        ),
      );
}

/// Category content.
@immutable
final class CategoryContent {
  CategoryContent._(this.category)
      : _categories = <CategoryEntity>[],
        _products = <ProductEntity>[];

  /// Current category.
  final CategoryEntity category;

  /// List of subcategories.
  final List<CategoryEntity> _categories;
  late final List<CategoryEntity> categories =
      UnmodifiableListView<CategoryEntity>(_categories);

  /// List of products.
  final List<ProductEntity> _products;
  late final List<ProductEntity> products =
      UnmodifiableListView<ProductEntity>(_products);
}

class _InheritedCategories extends InheritedModel<CategoryID> {
  const _InheritedCategories({
    required this.root,
    required this.table,
    required super.child,
    super.key, // ignore: unused_element
  });

  /// List of root categories.
  final List<CategoryEntity> root;

  /// Table of categories.
  final Map<CategoryID, CategoryContent> table;

  static _InheritedCategories? maybeOf(BuildContext context,
          {bool listen = true}) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<_InheritedCategories>()
          : context.getInheritedWidgetOfExactType<_InheritedCategories>();

  /// Get list of root categories.
  static List<CategoryEntity> getRootCategories(
    BuildContext context, {
    bool listen = true,
  }) =>
      (listen
              ? InheritedModel.inheritFrom<_InheritedCategories>(context,
                  aspect: null)
              : maybeOf(context, listen: false))
          ?.root ??
      <CategoryEntity>[];

  /// Get category content by id.
  static CategoryContent? getById(
    BuildContext context,
    CategoryID id, {
    bool listen = true,
  }) =>
      (listen
              ? InheritedModel.inheritFrom<_InheritedCategories>(context,
                  aspect: id)
              : maybeOf(context, listen: false))
          ?.table[id];

  @override
  bool updateShouldNotify(covariant _InheritedCategories oldWidget) =>
      !identical(root, oldWidget.root) || !identical(table, oldWidget.table);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedCategories oldWidget,
    Set<CategoryID> aspects,
  ) {
    for (final id in aspects) {
      if (table[id]?.category != oldWidget.table[id]?.category) return true;
    }
    return false;
  }
}

class _InheritedProducts extends InheritedModel<ProductID> {
  const _InheritedProducts({
    required this.table,
    required super.child,
    super.key, // ignore: unused_element
  });

  /// Table of products.
  final Map<ProductID, ProductEntity> table;

  static _InheritedProducts? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<_InheritedProducts>()
          : context.getInheritedWidgetOfExactType<_InheritedProducts>();

  /// Get product by id.
  static ProductEntity? getById(
    BuildContext context,
    ProductID id, {
    bool listen = true,
  }) =>
      (listen
              ? InheritedModel.inheritFrom<_InheritedProducts>(
                  context,
                  aspect: id,
                )
              : maybeOf(context, listen: false))
          ?.table[id];

  @override
  bool updateShouldNotify(covariant _InheritedProducts oldWidget) =>
      !identical(table, oldWidget.table);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedProducts oldWidget,
    Set<ProductID> aspects,
  ) {
    for (final id in aspects) {
      if (table[id] != oldWidget.table[id]) return true;
    }
    return false;
  }
}

class _InheritedFavorite extends InheritedModel<ProductID> {
  const _InheritedFavorite({
    required this.favorites,
    required super.child,
    super.key, // ignore: unused_element
  });

  final Set<ProductID> favorites;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `_InheritedFavorite.maybeOf(context)`.
  static _InheritedFavorite? maybeOf(BuildContext context,
          {bool listen = true}) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<_InheritedFavorite>()
          : context.getInheritedWidgetOfExactType<_InheritedFavorite>();

  static Set<ProductID> getFavorites(
    BuildContext context, {
    bool listen = true,
  }) =>
      maybeOf(context, listen: listen)?.favorites ?? <ProductID>{};

  static bool isFavorite(
    BuildContext context,
    ProductID id, {
    bool listen = true,
  }) =>
      (listen
              ? InheritedModel.inheritFrom<_InheritedFavorite>(
                  context,
                  aspect: id,
                )
              : maybeOf(context, listen: false))
          ?.favorites
          .contains(id) ??
      false;

  @override
  bool updateShouldNotify(covariant _InheritedFavorite oldWidget) =>
      !setEquals(favorites, oldWidget.favorites);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedFavorite oldWidget,
    Set<ProductID> aspects,
  ) {
    for (final id in aspects) {
      if (favorites.contains(id) != oldWidget.favorites.contains(id))
        return true;
    }
    return false;
  }
}
