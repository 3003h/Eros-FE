import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'ehconfig_service.dart';

class ThemeService extends ProfileService {
  final EhConfigService _ehConfigService = Get.find();
  final Rx<ThemesModeEnum> _themeModel = ThemesModeEnum.system.obs;
  Rx<Brightness> platformBrightness =
      WidgetsBinding.instance.window.platformBrightness.obs;

  set themeModel(ThemesModeEnum value) {
    _themeModel.value = value;
  }

  ThemesModeEnum get themeModel {
    return _themeModel.value;
  }

  CupertinoThemeData get _getDarkTheme => _ehConfigService.isPureDarkTheme.value
      ? ThemeColors.darkPureTheme
      : ThemeColors.darkGrayTheme;

  CupertinoThemeData get themeData {
    switch (themeModel) {
      case ThemesModeEnum.system:
        return platformBrightness.value == Brightness.dark
            ? _getDarkTheme
            : ThemeColors.ligthTheme;
      case ThemesModeEnum.ligthMode:
        return ThemeColors.ligthTheme;
      case ThemesModeEnum.darkMode:
        return _getDarkTheme;
      default:
        return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _themeModel.value =
        EnumToString.fromString(ThemesModeEnum.values, Global.profile.theme) ??
            ThemesModeEnum.system;
    everFromEunm(_themeModel, (String value) {
      Global.profile.theme = value;
    });
  }
}

final EHTheme ehTheme = EHTheme();

class EHTheme {
  final ThemeService _themeService = Get.find();
  final EhConfigService _ehConfigService = Get.find();
  Color get itemBackgroundColor {
    switch (_themeService.themeModel) {
      case ThemesModeEnum.system:
        return _themeService.platformBrightness.value == Brightness.dark
            ? _darkItemColor
            : ThemeColors.ligthItemBackground;
      case ThemesModeEnum.ligthMode:
        return ThemeColors.ligthItemBackground;
      case ThemesModeEnum.darkMode:
        return _darkItemColor;
      default:
        return null;
    }
  }

  Color get textFieldBackgroundColor {
    switch (_themeService.themeModel) {
      case ThemesModeEnum.system:
        return _themeService.platformBrightness.value == Brightness.dark
            ? _darkTextFieldColor
            : ThemeColors.ligthTextFieldBackground;
      case ThemesModeEnum.ligthMode:
        return ThemeColors.ligthTextFieldBackground;
      case ThemesModeEnum.darkMode:
        return _darkTextFieldColor;
      default:
        return null;
    }
  }

  CupertinoThemeData get themeData => _themeService.themeData;

  Color get _darkItemColor => _ehConfigService.isPureDarkTheme.value
      ? ThemeColors.darkItemBackground
      : ThemeColors.darkGrayItemBackground;

  Color get _darkTextFieldColor => _ehConfigService.isPureDarkTheme.value
      ? ThemeColors.darkTextFieldBackground
      : ThemeColors.darkGrayTextFieldBackground;

  bool get _isSeldark => _themeService.themeModel == ThemesModeEnum.darkMode;
  bool get _isSelLigth => _themeService.themeModel == ThemesModeEnum.ligthMode;

  bool get isDarkMode {
    if (_isSelLigth) {
      return false;
    } else {
      return _isSeldark ||
          _themeService.platformBrightness.value == Brightness.dark;
    }
  }
}
