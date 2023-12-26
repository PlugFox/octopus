import 'dart:math' as math;

import 'package:example/src/common/constant/config.dart';
import 'package:example/src/common/controller/state_consumer.dart';
import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/authentication/controller/authentication_controller.dart';
import 'package:example/src/feature/authentication/controller/authentication_state.dart';
import 'package:example/src/feature/authentication/model/sign_in_data.dart';
import 'package:example/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

/// {@template signin_screen}
/// SignInScreen widget.
/// {@endtemplate}
class SignInScreen extends StatefulWidget {
  /// {@macro signin_screen}
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with _UsernamePasswordFormStateMixin {
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  late final Listenable _formChangedNotifier =
      Listenable.merge([_usernameController, _passwordController]);
  final _usernameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(
      /// Allow only letters, numbers,
      /// and the following characters: @.-_+
      RegExp(r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+'),
    ),
    const _UsernameTextFormatter(),
  ];
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: math.max(16, (constraints.maxWidth - 620) / 2),
                ),
                child: StateConsumer<AuthenticationState>(
                  controller: _authenticationController,
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state, _) => Column(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(width: 50),
                            Text(
                              'Sign-In',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(height: 1),
                            ),
                            const SizedBox(width: 2),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(Icons.casino),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 48,
                                  height: 48,
                                ),
                                tooltip: 'Generate password',
                                onPressed: state.isIdling
                                    ? () {
                                        if (_obscurePassword)
                                          setState(
                                            () => _obscurePassword = false,
                                          );
                                        generatePassword();
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        focusNode: _usernameFocusNode,
                        enabled: state.isIdling,
                        maxLines: 1,
                        minLines: 1,
                        controller: _usernameController,
                        autocorrect: false,
                        autofillHints: const <String>[
                          AutofillHints.username,
                          AutofillHints.email
                        ],
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: _usernameFormatters,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          helperText: '',
                          helperMaxLines: 1,
                          errorText: _usernameError ?? state.error,
                          errorMaxLines: 1,
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        focusNode: _passwordFocusNode,
                        enabled: state.isIdling,
                        maxLines: 1,
                        minLines: 1,
                        controller: _passwordController,
                        autocorrect: false,
                        obscureText: _obscurePassword,
                        maxLength: Config.passwordMaxLength,
                        autofillHints: const <String>[AutofillHints.password],
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          helperText: '',
                          helperMaxLines: 1,
                          errorText: _passwordError ?? state.error,
                          errorMaxLines: 1,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: AnimatedBuilder(
                          animation: _formChangedNotifier,
                          builder: (context, _) {
                            final formFilled =
                                _usernameController.text.length > 3 &&
                                    _passwordController.text.length >=
                                        Config.passwordMinLength;
                            final signInCallback = state.isIdling && formFilled
                                ? () => signIn(context)
                                : null;
                            final signUpCallback =
                                state.isIdling ? () => signUp(context) : null;
                            final key = ValueKey<int>(
                                (signInCallback == null ? 0 : 1 << 1) |
                                    (signUpCallback == null ? 0 : 1));
                            return _SignInScreen$Buttons(
                              signIn: signInCallback,
                              signUp: signUpCallback,
                              key: key,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _SignInScreen$Buttons extends StatelessWidget {
  const _SignInScreen$Buttons({
    required this.signIn,
    required this.signUp,
    super.key,
  });

  final void Function()? signIn;
  final void Function()? signUp;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: signIn,
              icon: const Icon(Icons.login),
              label: const Text(
                'Sign-In',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: FilledButton.tonalIcon(
              onPressed: signUp,
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Sign-Up',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
}

class _UsernameTextFormatter extends TextInputFormatter {
  const _UsernameTextFormatter();
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      TextEditingValue(
        text: newValue.text.toLowerCase(),
        selection: newValue.selection,
      );
}

mixin _UsernamePasswordFormStateMixin on State<SignInScreen> {
  static String? _usernameValidator(String username) {
    if (username.isEmpty) return 'Username is required.';
    final length = switch (username.length) {
      0 => 'Password is required.',
      < 3 => 'Must be a valid email.',
      _ => null,
    };
    if (length != null) return length;
    if (username.split('@').where((e) => e.isNotEmpty).length != 2)
      return 'Must be a valid email.';
    // If username passes all checks, return null
    return null;
  }

  static String? _passwordValidator(String password) {
    const passwordMinLength = Config.passwordMinLength,
        passwordMaxLength = Config.passwordMaxLength;
    final length = switch (password.length) {
      0 => 'Password is required.',
      < passwordMinLength => 'Password must be 8 characters or more.',
      > passwordMaxLength => 'Password must be 32 characters or less.',
      _ => null,
    };
    if (length != null) return length;
    if (!password.contains(RegExp('[A-Z]')))
      return 'Password must have at least one uppercase character.';
    if (!password.contains(RegExp('[a-z]')))
      return 'Password must have at least one lowercase character.';
    // If password passes all checks, return null
    return null;
  }

  late final AuthenticationController _authenticationController;
  final TextEditingController _usernameController =
      TextEditingController(text: 'test@gmail.com');
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError, _passwordError;

  bool _validate(String username, String password) {
    final usernameError = _usernameValidator(username);
    final passwordError = _passwordValidator(password);
    if (mounted) {
      setState(() {
        _usernameError = usernameError;
        _passwordError = passwordError;
      });
    }
    return usernameError == null && passwordError == null;
  }

  /// Signs in the user with the given username and password
  void signIn(BuildContext context) {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (!_validate(username, password)) return;
    FocusScope.of(context).unfocus();
    _authenticationController.signIn(
      SignInData(
        username: username,
        password: password,
      ),
    );
  }

  /// Generates a random password
  void generatePassword() {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const chars = lower + upper + numbers;
    final rnd = math.Random();
    final length =
        rnd.nextInt(Config.passwordMaxLength - Config.passwordMinLength) +
            Config.passwordMinLength;
    final password = <int>[
      lower.codeUnitAt(rnd.nextInt(lower.length)),
      upper.codeUnitAt(rnd.nextInt(upper.length)),
      numbers.codeUnitAt(rnd.nextInt(numbers.length)),
      for (var i = 0; i < length - 3; i++)
        chars.codeUnitAt(rnd.nextInt(chars.length)),
    ];
    _passwordController.text = String.fromCharCodes(password..shuffle());
  }

  /// Opens the sign up page in the browser
  void signUp(BuildContext context) {
    FocusScope.of(context).unfocus();
    // url_launcher.launchUrlString('...').ignore();
    // context.octopus.setState((state) => state..add(Routes.signup.node()));
    context.octopus.push(Routes.signup);
  }

  @override
  void initState() {
    super.initState();
    _authenticationController = AuthenticationScope.controllerOf(context);
    generatePassword();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }
}
