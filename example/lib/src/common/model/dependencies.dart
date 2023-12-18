import 'package:example/src/feature/authentication/controller/authentication_controller.dart';
import 'package:example/src/feature/initialization/widget/inherited_dependencies.dart';
import 'package:example/src/feature/shop/controller/favorite_controller.dart';
import 'package:example/src/feature/shop/controller/shop_controller.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:shared_preferences/shared_preferences.dart';

/// Dependencies
class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);

  /// Shared preferences
  late final SharedPreferences sharedPreferences;

  /// Authentication controller
  late final AuthenticationController authenticationController;

  /// Shop controller
  late final ShopController shopController;

  /// Favorite controller
  late final FavoriteController favoriteController;
}
