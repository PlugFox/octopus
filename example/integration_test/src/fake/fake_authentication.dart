import 'dart:async';

import 'package:example/src/feature/authentication/data/authentication_repository.dart';
import 'package:example/src/feature/authentication/model/sign_in_data.dart';
import 'package:example/src/feature/authentication/model/user.dart';

class FakeIAuthenticationRepositoryImpl implements IAuthenticationRepository {
  FakeIAuthenticationRepositoryImpl();

  static const String _sessionKey = 'authentication.session';
  final Map<String, Object?> _sharedPreferences = <String, Object?>{};
  final StreamController<User> _userController =
      StreamController<User>.broadcast();
  User _user = const User.unauthenticated();

  @override
  FutureOr<User> getUser() => _user;

  @override
  Stream<User> userChanges() => _userController.stream;

  @override
  Future<void> signIn(SignInData data) async {
    final user = User.authenticated(id: data.username);
    _sharedPreferences[_sessionKey] = user.toJson();
    _userController.add(_user = user);
  }

  @override
  Future<void> restore() async {
    final session = _sharedPreferences[_sessionKey];
    if (session == null) return;
    final json = session;
    if (json case Map<String, Object?> jsonMap) {
      final user = User.fromJson(jsonMap);
      _userController.add(_user = user);
    }
  }

  @override
  Future<void> signOut() => Future<void>.sync(
        () {
          const user = User.unauthenticated();
          _sharedPreferences.remove(_sessionKey);
          _userController.add(_user = user);
        },
      );
}
