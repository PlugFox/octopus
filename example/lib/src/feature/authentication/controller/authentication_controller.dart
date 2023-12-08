import 'dart:async';

import 'package:example/src/common/controller/droppable_controller_concurrency.dart';
import 'package:example/src/common/controller/state_controller.dart';
import 'package:example/src/feature/authentication/controller/authentication_state.dart';
import 'package:example/src/feature/authentication/data/authentication_repository.dart';
import 'package:example/src/feature/authentication/model/sign_in_data.dart';
import 'package:example/src/feature/authentication/model/user.dart';

final class AuthenticationController
    extends StateController<AuthenticationState>
    with DroppableControllerConcurrency {
  AuthenticationController(
      {required IAuthenticationRepository repository,
      super.initialState =
          const AuthenticationState.idle(user: User.unauthenticated())})
      : _repository = repository {
    _userSubscription = repository
        .userChanges()
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .where((newState) =>
            state.isProcessing || !identical(newState.user, state.user))
        .listen(setState, cancelOnError: false);
  }

  final IAuthenticationRepository _repository;
  StreamSubscription<AuthenticationState>? _userSubscription;

  /// Restore the session from the cache.
  void restore() => handle(
        () async {
          setState(
            AuthenticationState.processing(
              user: state.user,
              message: 'Restoring session...',
            ),
          );
          await _repository.restore();
        },
        (error, _) => setState(
          const AuthenticationState.idle(
            user: User.unauthenticated(),
            error: 'Restore Error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          AuthenticationState.idle(user: state.user),
        ),
      );

  /// Sign in with the given [data].
  void signIn(SignInData data) => handle(
        () async {
          setState(
            AuthenticationState.processing(
              user: state.user,
              message: 'Logging in...',
            ),
          );
          await _repository.signIn(data);
        },
        (error, _) => setState(
          AuthenticationState.idle(
            user: state.user,
            error: 'Sign In Error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          AuthenticationState.idle(user: state.user),
        ),
      );

  /// Sign out.
  void signOut() => handle(
        () async {
          setState(
            AuthenticationState.processing(
              user: state.user,
              message: 'Logging out...',
            ),
          );
          await _repository.signOut();
        },
        (error, _) => setState(
          AuthenticationState.idle(
            user: state.user,
            error: 'Log Out Error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          const AuthenticationState.idle(
            user: User.unauthenticated(),
          ),
        ),
      );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
