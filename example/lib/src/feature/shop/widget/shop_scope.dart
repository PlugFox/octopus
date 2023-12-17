import 'dart:collection';

import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/feature/shop/controller/shop_controller.dart';
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
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

  @override
  State<ShopScope> createState() => _ShopScopeState();
}

/// State for widget ShopScope.
class _ShopScopeState extends State<ShopScope> {
  late final ShopController _controller;
  List<CategoryEntity> _categories = <CategoryEntity>[];
  List<ProductEntity> _products = <ProductEntity>[];
  List<CategoryEntity> _rootCategories = <CategoryEntity>[];
  Map<CategoryID, CategoryContent> _tableCategories =
      <CategoryID, CategoryContent>{};
  Map<ProductID, ProductEntity> _tableProduct = <ProductID, ProductEntity>{};

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _controller = Dependencies.of(context).shopController;
    _controller.addListener(_onStateChanged);
    _onStateChanged();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    super.dispose();
  }
  /* #endregion */

  void _onStateChanged() {
    if (!mounted) return;
    if (identical(_categories, _controller.state.categories)) return;
    if (identical(_products, _controller.state.products)) return;
    _categories = _controller.state.categories;
    _products = _controller.state.products;
    _rootCategories = <CategoryEntity>[];
    _tableCategories = <CategoryID, CategoryContent>{};
    _tableProduct = <ProductID, ProductEntity>{};
    for (final category in _controller.state.categories) {
      if (category.isRoot) _rootCategories.add(category);
      _tableCategories[category.id] = CategoryContent._(category);
    }
    for (final product in _controller.state.products) {
      _tableProduct[product.id] = product;
      _tableCategories[product.category]?._products.add(product);
    }
    for (final category in _controller.state.categories) {
      if (category.isRoot) continue;
      _tableCategories[category.parent]?._categories.add(category);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _InheritedCategories(
        root: _rootCategories,
        table: _tableCategories,
        child: _InheritedProducts(
          table: _tableProduct,
          child: widget.child,
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
