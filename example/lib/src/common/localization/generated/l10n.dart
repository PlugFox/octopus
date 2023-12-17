// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class GeneratedLocalization {
  GeneratedLocalization();

  static GeneratedLocalization? _current;

  static GeneratedLocalization get current {
    assert(_current != null,
        'No instance of GeneratedLocalization was loaded. Try to initialize the GeneratedLocalization delegate before accessing GeneratedLocalization.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<GeneratedLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = GeneratedLocalization();
      GeneratedLocalization._current = instance;

      return instance;
    });
  }

  static GeneratedLocalization of(BuildContext context) {
    final instance = GeneratedLocalization.maybeOf(context);
    assert(instance != null,
        'No instance of GeneratedLocalization present in the widget tree. Did you add GeneratedLocalization.delegate in localizationsDelegates?');
    return instance!;
  }

  static GeneratedLocalization? maybeOf(BuildContext context) {
    return Localizations.of<GeneratedLocalization>(
        context, GeneratedLocalization);
  }

  /// `en_US`
  String get localeCode {
    return Intl.message(
      'en_US',
      name: 'localeCode',
      desc: '',
      args: [],
    );
  }

  /// `en`
  String get languageCode {
    return Intl.message(
      'en',
      name: 'languageCode',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Octopus`
  String get title {
    return Intl.message(
      'Octopus',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Routes`
  String get routes {
    return Intl.message(
      'Routes',
      name: 'routes',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get recent {
    return Intl.message(
      'Recent',
      name: 'recent',
      desc: '',
      args: [],
    );
  }

  /// `Starred`
  String get starred {
    return Intl.message(
      'Starred',
      name: 'starred',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Developer`
  String get developer {
    return Intl.message(
      'Developer',
      name: 'developer',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Exception`
  String get exception {
    return Intl.message(
      'Exception',
      name: 'exception',
      desc: '',
      args: [],
    );
  }

  /// `An error has occurred`
  String get anErrorHasOccurred {
    return Intl.message(
      'An error has occurred',
      name: 'anErrorHasOccurred',
      desc: '',
      args: [],
    );
  }

  /// `An exception has occurred`
  String get anExceptionHasOccurred {
    return Intl.message(
      'An exception has occurred',
      name: 'anExceptionHasOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Please try again later.`
  String get tryAgainLater {
    return Intl.message(
      'Please try again later.',
      name: 'tryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Invalid format`
  String get invalidFormat {
    return Intl.message(
      'Invalid format',
      name: 'invalidFormat',
      desc: '',
      args: [],
    );
  }

  /// `Time out exceeded`
  String get timeOutExceeded {
    return Intl.message(
      'Time out exceeded',
      name: 'timeOutExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Invalid credentials`
  String get invalidCredentials {
    return Intl.message(
      'Invalid credentials',
      name: 'invalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Unimplemented`
  String get unimplemented {
    return Intl.message(
      'Unimplemented',
      name: 'unimplemented',
      desc: '',
      args: [],
    );
  }

  /// `Not implemented yet`
  String get notImplementedYet {
    return Intl.message(
      'Not implemented yet',
      name: 'notImplementedYet',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported operation`
  String get unsupportedOperation {
    return Intl.message(
      'Unsupported operation',
      name: 'unsupportedOperation',
      desc: '',
      args: [],
    );
  }

  /// `File system error`
  String get fileSystemException {
    return Intl.message(
      'File system error',
      name: 'fileSystemException',
      desc: '',
      args: [],
    );
  }

  /// `Assertion error`
  String get assertionError {
    return Intl.message(
      'Assertion error',
      name: 'assertionError',
      desc: '',
      args: [],
    );
  }

  /// `Bad state error`
  String get badStateError {
    return Intl.message(
      'Bad state error',
      name: 'badStateError',
      desc: '',
      args: [],
    );
  }

  /// `Bad request`
  String get badRequest {
    return Intl.message(
      'Bad request',
      name: 'badRequest',
      desc: '',
      args: [],
    );
  }

  /// `Unauthorized`
  String get unauthorized {
    return Intl.message(
      'Unauthorized',
      name: 'unauthorized',
      desc: '',
      args: [],
    );
  }

  /// `Forbidden`
  String get forbidden {
    return Intl.message(
      'Forbidden',
      name: 'forbidden',
      desc: '',
      args: [],
    );
  }

  /// `Not found`
  String get notFound {
    return Intl.message(
      'Not found',
      name: 'notFound',
      desc: '',
      args: [],
    );
  }

  /// `Not acceptable`
  String get notAcceptable {
    return Intl.message(
      'Not acceptable',
      name: 'notAcceptable',
      desc: '',
      args: [],
    );
  }

  /// `Request timeout`
  String get requestTimeout {
    return Intl.message(
      'Request timeout',
      name: 'requestTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Too many requests`
  String get tooManyRequests {
    return Intl.message(
      'Too many requests',
      name: 'tooManyRequests',
      desc: '',
      args: [],
    );
  }

  /// `Internal server error`
  String get internalServerError {
    return Intl.message(
      'Internal server error',
      name: 'internalServerError',
      desc: '',
      args: [],
    );
  }

  /// `Bad gateway`
  String get badGateway {
    return Intl.message(
      'Bad gateway',
      name: 'badGateway',
      desc: '',
      args: [],
    );
  }

  /// `Service unavailable`
  String get serviceUnavailable {
    return Intl.message(
      'Service unavailable',
      name: 'serviceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Gateway timeout`
  String get gatewayTimeout {
    return Intl.message(
      'Gateway timeout',
      name: 'gatewayTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Unknown server error`
  String get unknownServerError {
    return Intl.message(
      'Unknown server error',
      name: 'unknownServerError',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error was received from the server`
  String get anUnknownErrorWasReceivedFromTheServer {
    return Intl.message(
      'An unknown error was received from the server',
      name: 'anUnknownErrorWasReceivedFromTheServer',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOutButton {
    return Intl.message(
      'Log Out',
      name: 'logOutButton',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get logInButton {
    return Intl.message(
      'Log In',
      name: 'logInButton',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exitButton {
    return Intl.message(
      'Exit',
      name: 'exitButton',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUpButton {
    return Intl.message(
      'Sign Up',
      name: 'signUpButton',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signInButton {
    return Intl.message(
      'Sign In',
      name: 'signInButton',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get backButton {
    return Intl.message(
      'Back',
      name: 'backButton',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message(
      'Cancel',
      name: 'cancelButton',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirmButton {
    return Intl.message(
      'Confirm',
      name: 'confirmButton',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveButton {
    return Intl.message(
      'Save',
      name: 'saveButton',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get createButton {
    return Intl.message(
      'Create',
      name: 'createButton',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message(
      'Delete',
      name: 'deleteButton',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editButton {
    return Intl.message(
      'Edit',
      name: 'editButton',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addButton {
    return Intl.message(
      'Add',
      name: 'addButton',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copyButton {
    return Intl.message(
      'Copy',
      name: 'copyButton',
      desc: '',
      args: [],
    );
  }

  /// `Move`
  String get moveButton {
    return Intl.message(
      'Move',
      name: 'moveButton',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get renameButton {
    return Intl.message(
      'Rename',
      name: 'renameButton',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get uploadButton {
    return Intl.message(
      'Upload',
      name: 'uploadButton',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get downloadButton {
    return Intl.message(
      'Download',
      name: 'downloadButton',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get shareButton {
    return Intl.message(
      'Share',
      name: 'shareButton',
      desc: '',
      args: [],
    );
  }

  /// `Share link`
  String get shareLinkButton {
    return Intl.message(
      'Share link',
      name: 'shareLinkButton',
      desc: '',
      args: [],
    );
  }

  /// `Remove from starred`
  String get removeFromStarredButton {
    return Intl.message(
      'Remove from starred',
      name: 'removeFromStarredButton',
      desc: '',
      args: [],
    );
  }

  /// `Add to starred`
  String get addToStarredButton {
    return Intl.message(
      'Add to starred',
      name: 'addToStarredButton',
      desc: '',
      args: [],
    );
  }

  /// `Move to trash`
  String get moveToTrashButton {
    return Intl.message(
      'Move to trash',
      name: 'moveToTrashButton',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restoreButton {
    return Intl.message(
      'Restore',
      name: 'restoreButton',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Surname`
  String get surname {
    return Intl.message(
      'Surname',
      name: 'surname',
      desc: '',
      args: [],
    );
  }

  /// `Language selection`
  String get languageSelection {
    return Intl.message(
      'Language selection',
      name: 'languageSelection',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade`
  String get upgrade {
    return Intl.message(
      'Upgrade',
      name: 'upgrade',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get app {
    return Intl.message(
      'App',
      name: 'app',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get application {
    return Intl.message(
      'Application',
      name: 'application',
      desc: '',
      args: [],
    );
  }

  /// `Authenticate`
  String get authenticate {
    return Intl.message(
      'Authenticate',
      name: 'authenticate',
      desc: '',
      args: [],
    );
  }

  /// `Authenticated`
  String get authenticated {
    return Intl.message(
      'Authenticated',
      name: 'authenticated',
      desc: '',
      args: [],
    );
  }

  /// `Authentication`
  String get authentication {
    return Intl.message(
      'Authentication',
      name: 'authentication',
      desc: '',
      args: [],
    );
  }

  /// `Navigation`
  String get navigation {
    return Intl.message(
      'Navigation',
      name: 'navigation',
      desc: '',
      args: [],
    );
  }

  /// `Database`
  String get database {
    return Intl.message(
      'Database',
      name: 'database',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  /// `Useful links`
  String get usefulLinks {
    return Intl.message(
      'Useful links',
      name: 'usefulLinks',
      desc: '',
      args: [],
    );
  }

  /// `You will be logged out from your account`
  String get logOutDescription {
    return Intl.message(
      'You will be logged out from your account',
      name: 'logOutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Current version`
  String get currentVersion {
    return Intl.message(
      'Current version',
      name: 'currentVersion',
      desc: '',
      args: [],
    );
  }

  /// `Latest version`
  String get latestVersion {
    return Intl.message(
      'Latest version',
      name: 'latestVersion',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get size {
    return Intl.message(
      'Size',
      name: 'size',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get currentLabel {
    return Intl.message(
      'Current',
      name: 'currentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Current user`
  String get currentUser {
    return Intl.message(
      'Current user',
      name: 'currentUser',
      desc: '',
      args: [],
    );
  }

  /// `Application version`
  String get applicationVersion {
    return Intl.message(
      'Application version',
      name: 'applicationVersion',
      desc: '',
      args: [],
    );
  }

  /// `Application information`
  String get applicationInformation {
    return Intl.message(
      'Application information',
      name: 'applicationInformation',
      desc: '',
      args: [],
    );
  }

  /// `Connected devices`
  String get conectedDevices {
    return Intl.message(
      'Connected devices',
      name: 'conectedDevices',
      desc: '',
      args: [],
    );
  }

  /// `Renewal date`
  String get renewalDate {
    return Intl.message(
      'Renewal date',
      name: 'renewalDate',
      desc: '',
      args: [],
    );
  }

  /// `API domain`
  String get apiDomain {
    return Intl.message(
      'API domain',
      name: 'apiDomain',
      desc: '',
      args: [],
    );
  }

  /// `No plan`
  String get noPlan {
    return Intl.message(
      'No plan',
      name: 'noPlan',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get storage {
    return Intl.message(
      'Storage',
      name: 'storage',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get ofSeparator {
    return Intl.message(
      'of',
      name: 'ofSeparator',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<GeneratedLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<GeneratedLocalization> load(Locale locale) =>
      GeneratedLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
