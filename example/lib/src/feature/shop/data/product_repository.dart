import 'dart:convert';

import 'package:example/src/common/constant/assets.gen.dart' as assets;
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

abstract class IProductRepository {
  Stream<CategoryEntity> fetchCategories();
  Stream<ProductEntity> fetchProducts();
}

class ProductRepositoryImpl implements IProductRepository {
  ProductRepositoryImpl();

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

  static List<Map<String, Object?>> _extractCollection(String json) =>
      (jsonDecode(json) as Map<String, Object?>)
          .values
          .whereType<Iterable<Object?>>()
          .reduce((v, e) => <Object?>[...v, ...e])
          .whereType<Map<String, Object?>>()
          .toList(growable: false);
}
