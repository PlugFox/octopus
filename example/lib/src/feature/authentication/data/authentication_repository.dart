import 'dart:async';

import 'package:example/src/feature/authentication/model/sign_in_data.dart';
import 'package:example/src/feature/authentication/model/user.dart';

abstract interface class IAuthenticationRepository {
  Stream<User> userChanges();
  FutureOr<User> getUser();
  Future<void> signIn(SignInData data);
  Future<void> signOut();
}

class AuthenticationRepositoryImpl implements IAuthenticationRepository {
  AuthenticationRepositoryImpl();
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
        () => _userController.add(
          _user = User.authenticated(id: data.username),
        ),
      );

  @override
  Future<void> signOut() => Future<void>.sync(
        () => _userController.add(
          _user = const User.unauthenticated(),
        ),
      );
}
