import 'package:example/src/common/model/dependencies.dart';
import 'package:example/src/feature/authentication/controller/authentication_controller.dart';
import 'package:example/src/feature/shop/controller/favorite_controller.dart';
import 'package:example/src/feature/shop/controller/shop_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_authentication.dart';
import 'fake_product.dart';

Future<FakeDependencies> $initializeFakeDependencies() async {
  SharedPreferences.setMockInitialValues(<String, String>{});
  final fakeProductRepository = FakeProductRepository();
  final dependencies = FakeDependencies()
    ..sharedPreferences = await SharedPreferences.getInstance()
    ..authenticationController = AuthenticationController(
      repository: FakeIAuthenticationRepositoryImpl(),
    )
    ..shopController = ShopController(
      repository: fakeProductRepository,
    )
    ..favoriteController = FavoriteController(
      repository: fakeProductRepository,
    );
  return dependencies;
}

/// Fake Dependencies
class FakeDependencies implements Dependencies {
  FakeDependencies();

  /// The state from the closest instance of this class.
  static Dependencies of(BuildContext context) => Dependencies.of(context);

  /// Shared preferences
  @override
  late final SharedPreferences sharedPreferences;

  /// Authentication controller
  @override
  late final AuthenticationController authenticationController;

  /// Shop controller
  @override
  late final ShopController shopController;

  /// Favorite controller
  @override
  late final FavoriteController favoriteController;
}
