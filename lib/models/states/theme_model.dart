import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/base.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../profile.dart';

class ThemeModel extends ProfileChangeNotifier {
  Profile get _profile => Global.profile;
  bool get _pureDarkTheme => _profile.ehConfig.pureDarkTheme ?? false;

  // 获取当前主题，如果未设置主题，则默认设置为跟随系统
  ThemesModeEnum get themeMode =>
      EnumToString.fromString(ThemesModeEnum.values, _profile?.theme) ??
      ThemesModeEnum.system;

  CupertinoThemeData get _getDarkTheme =>
      _pureDarkTheme ? ThemeColors.darkPureTheme : ThemeColors.darkGrayTheme;

  CupertinoThemeData getTheme(BuildContext context, Brightness brightness) {
    switch (themeMode) {
      case ThemesModeEnum.system:
        return brightness == Brightness.dark
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

  // 主题改变后，通知其依赖项，新主题会立即生效
  set themeMode(ThemesModeEnum setThemesMode) {
    if (setThemesMode != themeMode) {
      _profile.theme = EnumToString.convertToString(setThemesMode);
      notifyListeners();
    }
  }

  bool get pureDarkTheme => _profile.ehConfig.pureDarkTheme ?? false;
  set pureDarkTheme(bool value) {
    _profile.ehConfig.pureDarkTheme = value;
    notifyListeners();
  }
}
