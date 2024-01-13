import 'dart:convert';

import 'package:example/src/common/constant/assets.gen.dart' as assets;
import 'package:example/src/feature/shop/data/product_repository.dart';
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FakeProductRepository implements IProductRepository {
  FakeProductRepository();

  static const String _favoriteProductsKey = 'shop.products.favorite';

  final Map<String, Object?> _sharedPreferences = <String, Object?>{};

  Set<ProductID>? _favoritesCache;

  @override
  Stream<CategoryEntity> fetchCategories() async* {
    final json = await rootBundle.loadString(assets.Assets.data.categories);
    final categories = await compute<String, List<Map<String, Object?>>>(
        _extractCollection, json);
    for (final category in categories) {
      yield CategoryEntity.fromJson(category);
    }
  }

  @override
  Stream<ProductEntity> fetchProducts() async* {
    final json = await rootBundle.loadString(assets.Assets.data.products);
    final products = await compute<String, List<Map<String, Object?>>>(
        _extractCollection, json);
    for (final product in products) {
      yield ProductEntity.fromJson(product);
    }
  }

  @override
  Future<Set<ProductID>> fetchFavoriteProducts() async {
    if (_favoritesCache case Set<ProductID> cache)
      return Set<ProductID>.of(cache);
    final set = _sharedPreferences[_favoriteProductsKey];
    if (set is! Iterable<String>) return <ProductID>{};
    return Set<ProductID>.of(_favoritesCache =
        set.map<int?>(int.tryParse).whereType<ProductID>().toSet());
  }

  @override
  Future<void> addFavoriteProduct(ProductID id) async {
    final set = await fetchFavoriteProducts();
    if (!set.add(id)) return;
    _favoritesCache = set;
    _sharedPreferences[_favoriteProductsKey] = <String>[
      ...set.map<String>((e) => e.toString()),
      id.toString(),
    ];
  }

  @override
  Future<void> removeFavoriteProduct(ProductID id) async {
    final set = await fetchFavoriteProducts();
    if (!set.remove(id)) return;
    _favoritesCache = set;
    _sharedPreferences[_favoriteProductsKey] = <String>[
      for (final e in set) e.toString(),
    ];
  }

  static List<Map<String, Object?>> _extractCollection(String json) =>
      (jsonDecode(json) as Map<String, Object?>)
          .values
          .whereType<Iterable<Object?>>()
          .reduce((v, e) => <Object?>[...v, ...e])
          .whereType<Map<String, Object?>>()
          .toList(growable: false);
}
