import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/values/theme_colors.dart';
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
