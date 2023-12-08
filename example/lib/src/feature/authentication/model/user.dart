import 'package:meta/meta.dart';

/// User id type.
typedef UserId = String;

/// {@template user}
/// The user entry model.
/// {@endtemplate}
@immutable
sealed class User with _UserPatternMatching, _UserShortcuts {
  /// {@macro user}
  const User._();

  /// {@macro user}
  @literal
  const factory User.unauthenticated() = UnauthenticatedUser;

  /// {@macro user}
  const factory User.authenticated({
    required UserId id,
  }) = AuthenticatedUser;

  /// {@macro user}
  factory User.fromJson(Map<String, Object?> json) => switch (json['id']) {
        UserId id => AuthenticatedUser(id: id),
        _ => const UnauthenticatedUser(),
      };

  /// The user's id.
  abstract final UserId? id;

  Map<String, Object?> toJson();
}

/// {@macro user}
///
/// Unauthenticated user.
class UnauthenticatedUser extends User {
  /// {@macro user}
  const UnauthenticatedUser() : super._();

  /// {@macro user}
  // ignore: avoid_unused_constructor_parameters
  factory UnauthenticatedUser.fromJson(Map<String, Object?> json) =>
      const UnauthenticatedUser();

  @override
  UserId? get id => null;

  @override
  bool get isAuthenticated => false;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'user',
        'status': 'unauthenticated',
        'authenticated': false,
        'id': null,
      };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) =>
      unauthenticated(this);

  @override
  User copyWith({
    UserId? id,
  }) =>
      id != null ? AuthenticatedUser(id: id) : const UnauthenticatedUser();

  @override
  int get hashCode => -1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnauthenticatedUser && id == other.id;

  @override
  String toString() => 'UnauthenticatedUser{}';
}

/// {@macro user}
final class AuthenticatedUser extends User {
  /// {@macro user}
  const AuthenticatedUser({
    required this.id,
  }) : super._();

  /// {@macro user}
  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    if (json.isEmpty) throw FormatException('Json is empty', json);
    if (json
        case <String, Object?>{
          'id': UserId id,
        }) return AuthenticatedUser(id: id);
    throw FormatException('Invalid json format', json);
  }

  @override
  @nonVirtual
  final UserId id;

  @override
  @nonVirtual
  bool get isAuthenticated => true;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'user',
        'status': 'authenticated',
        'authenticated': true,
        'id': id,
      };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) =>
      authenticated(this);

  @override
  AuthenticatedUser copyWith({
    UserId? id,
  }) =>
      AuthenticatedUser(
        id: id ?? this.id,
      );

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthenticatedUser && id == other.id;

  @override
  String toString() => 'AuthenticatedUser{id: $id}';
}

mixin _UserPatternMatching {
  /// Pattern matching on [User] subclasses.
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  });

  /// Pattern matching on [User] subclasses.
  T maybeMap<T>({
    required T Function() orElse,
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) =>
      map<T>(
        unauthenticated: (user) => unauthenticated?.call(user) ?? orElse(),
        authenticated: (user) => authenticated?.call(user) ?? orElse(),
      );

  /// Pattern matching on [User] subclasses.
  T? mapOrNull<T>({
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) =>
      map<T?>(
        unauthenticated: (user) => unauthenticated?.call(user),
        authenticated: (user) => authenticated?.call(user),
      );
}

mixin _UserShortcuts on _UserPatternMatching {
  /// User is authenticated.
  bool get isAuthenticated;

  /// User is not authenticated.
  bool get isNotAuthenticated => !isAuthenticated;

  /// Copy with new values.
  User copyWith({
    UserId? id,
  });
}
