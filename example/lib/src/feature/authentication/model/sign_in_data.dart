import 'package:flutter/material.dart';

@immutable
final class SignInData {
  const SignInData({
    required this.username,
    required this.password,
  });

  /// Username.
  final String username;

  /// Password.
  final String password;
}
