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
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();

  static S current;

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();

      return S.current;
    });
  }

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `FEhViewer`
  String get app_title {
    return Intl.message(
      'FEhViewer',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `~oh~ oh~ oh~~~`
  String get welcome_text {
    return Intl.message(
      '~oh~ oh~ oh~~~',
      name: 'welcome_text',
      desc: 'welcom Tex',
      args: [],
    );
  }

  /// `Popular`
  String get tab_popular {
    return Intl.message(
      'Popular',
      name: 'tab_popular',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get tab_gallery {
    return Intl.message(
      'Gallery',
      name: 'tab_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get tab_favorite {
    return Intl.message(
      'Favorites',
      name: 'tab_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get tab_setting {
    return Intl.message(
      'Settings',
      name: 'tab_setting',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favcat {
    return Intl.message(
      'Favorites',
      name: 'favcat',
      desc: '',
      args: [],
    );
  }

  /// `Not Favorited`
  String get notFav {
    return Intl.message(
      'Not Favorited',
      name: 'notFav',
      desc: '',
      args: [],
    );
  }

  /// `All Favorites`
  String get all_Favorites {
    return Intl.message(
      'All Favorites',
      name: 'all_Favorites',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `User Sign`
  String get user_login {
    return Intl.message(
      'User Sign',
      name: 'user_login',
      desc: '',
      args: [],
    );
  }

  /// `Please enter user name`
  String get pls_i_username {
    return Intl.message(
      'Please enter user name',
      name: 'pls_i_username',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pls_i_passwd {
    return Intl.message(
      'Please enter your password',
      name: 'pls_i_passwd',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get user_name {
    return Intl.message(
      'Username',
      name: 'user_name',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwd {
    return Intl.message(
      'Password',
      name: 'passwd',
      desc: '',
      args: [],
    );
  }

  /// `Sign`
  String get login {
    return Intl.message(
      'Sign',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Not Login`
  String get not_login {
    return Intl.message(
      'Not Login',
      name: 'not_login',
      desc: '',
      args: [],
    );
  }

  /// `Sign in on the web`
  String get login_web {
    return Intl.message(
      'Sign in on the web',
      name: 'login_web',
      desc: '',
      args: [],
    );
  }

  /// `Press again to exit`
  String get double_click_back {
    return Intl.message(
      'Press again to exit',
      name: 'double_click_back',
      desc: '',
      args: [],
    );
  }

  /// `READ`
  String get READ {
    return Intl.message(
      'READ',
      name: 'READ',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Comments`
  String get gallery_comments {
    return Intl.message(
      'Gallery Comments',
      name: 'gallery_comments',
      desc: '',
      args: [],
    );
  }

  /// `All Comment`
  String get all_comment {
    return Intl.message(
      'All Comment',
      name: 'all_comment',
      desc: '',
      args: [],
    );
  }

  /// `All Preview`
  String get all_preview {
    return Intl.message(
      'All Preview',
      name: 'all_preview',
      desc: '',
      args: [],
    );
  }

  /// `More previews`
  String get morePreviews {
    return Intl.message(
      'More previews',
      name: 'morePreviews',
      desc: '',
      args: [],
    );
  }

  /// `No more previews`
  String get noMorePreviews {
    return Intl.message(
      'No more previews',
      name: 'noMorePreviews',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}
