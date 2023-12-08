import 'dart:async';
import 'dart:convert';

import 'package:example/src/feature/authentication/model/sign_in_data.dart';
import 'package:example/src/feature/authentication/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IAuthenticationRepository {
  Stream<User> userChanges();
  FutureOr<User> getUser();
  Future<void> signIn(SignInData data);
  Future<void> restore();
  Future<void> signOut();
}

class AuthenticationRepositoryImpl implements IAuthenticationRepository {
  AuthenticationRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const String _sessionKey = 'authentication.session';
  final SharedPreferences _sharedPreferences;
  final StreamController<User> _userController =
      StreamController<User>.broadcast();
  User _user = const User.unauthenticated();

  @override
  FutureOr<User> getUser() => _user;

  @override
  Stream<User> userChanges() => _userController.stream;

  @override
  Future<void> signIn(SignInData data) => Future<void>.delayed(
        const Duration(seconds: 1),
        () {
          final user = User.authenticated(id: data.username);
          _sharedPreferences
              .setString(_sessionKey, jsonEncode(user.toJson()))
              .ignore();
          _userController.add(_user = user);
        },
      );

  @override
  Future<void> restore() async {
    final session = _sharedPreferences.getString(_sessionKey);
    if (session == null) return;
    final json = jsonDecode(session);
    if (json case Map<String, Object?> jsonMap) {
      final user = User.fromJson(jsonMap);
      _userController.add(_user = user);
    }
  }

  @override
  Future<void> signOut() => Future<void>.sync(
        () {
          const user = User.unauthenticated();
          _sharedPreferences.remove(_sessionKey).ignore();
          _userController.add(_user = user);
        },
      );
}
