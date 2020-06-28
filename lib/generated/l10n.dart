// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
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
      desc: '启动页提示语',
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

  /// `Favorite`
  String get tab_favorite {
    return Intl.message(
      'Favorite',
      name: 'tab_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get tab_setting {
    return Intl.message(
      'Setting',
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