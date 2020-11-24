import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ThemesModeEnum {
  system,
  ligthMode,
  darkMode,
}

class CustTheme {
  CupertinoThemeData themeData;
}

// ignore: avoid_classes_with_only_static_members
class ThemeColors {
  static const CupertinoDynamicColor commitBackground =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'commitBackground',
    color: Color.fromARGB(255, 242, 242, 247),
    darkColor: Color.fromARGB(255, 30, 30, 30),
  );

  // Gray
  static const CupertinoDynamicColor commitBackgroundGray =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'commitBackground',
    color: Color.fromARGB(255, 242, 242, 247),
    darkColor: Color.fromARGB(255, 60, 60, 60),
  );

  static const CupertinoDynamicColor pressedBackground =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'pressedBackground',
    color: Color.fromARGB(255, 209, 209, 214),
    darkColor: Color.fromARGB(255, 50, 50, 50),
  );

  static const CupertinoDynamicColor commitText =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'commitText',
    color: Colors.black87,
    darkColor: CupertinoColors.systemGrey4,
  );

  static const CupertinoDynamicColor tagText =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'tagText',
    color: Color(0xff505050),
    darkColor: CupertinoColors.systemGrey4,
  );

  static const CupertinoDynamicColor tagBackground =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'tagBackground',
    color: Color(0xffeeeeee),
    darkColor: CupertinoColors.secondaryLabel,
  );

  static const CupertinoDynamicColor line =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'line',
    color: Color(0xffeeeeee),
    darkColor: CupertinoColors.secondaryLabel,
  );

  static const Map<String, Color> tagColorTagType = {
    'artist': CupertinoDynamicColor.withBrightness(
      color: Color(0xffE6D6D0),
      darkColor: Color.fromARGB(255, 94, 84, 78),
    ),
    'female': CupertinoDynamicColor.withBrightness(
      color: Color(0xffFAE0D4),
      darkColor: Color.fromARGB(255, 144, 111, 68),
    ),
    'male': CupertinoDynamicColor.withBrightness(
      color: Color(0xfff9eed8),
      darkColor: Color.fromARGB(255, 150, 138, 74),
    ),
    'parody': CupertinoDynamicColor.withBrightness(
      color: Color(0xffd8e6e2),
      darkColor: Color.fromARGB(255, 72, 112, 104),
    ),
    'character': CupertinoDynamicColor.withBrightness(
      color: Color(0xffd5e4f7),
      darkColor: Color.fromARGB(255, 73, 103, 127),
    ),
    'group': CupertinoDynamicColor.withBrightness(
      color: Color(0xffdfd6f7),
      darkColor: Color.fromARGB(255, 97, 82, 132),
    ),
    'language': CupertinoDynamicColor.withBrightness(
      color: Color(0xfff5d5e5),
      darkColor: Color.fromARGB(255, 127, 74, 107),
    ),
    'reclass': CupertinoDynamicColor.withBrightness(
      color: Color(0xfffbd6d5),
      darkColor: Color.fromARGB(255, 146, 85, 84),
    ),
    'misc': CupertinoDynamicColor.withBrightness(
      color: Color(0xffd7d7d6),
      darkColor: Color.fromARGB(255, 99, 102, 106),
    ),
  };

  static const Map<String, Color> tagColorTagType2 = {
    'artist': Color(0xffE6D6D0),
    'female': Color(0xffFAE0D4),
    'male': Color(0xfff9eed8),
    'parody': Color(0xffd8e6e2),
    'character': Color(0xffd5e4f7),
    'group': Color(0xffdfd6f7),
    'language': Color(0xfff5d5e5),
    'reclass': Color(0xfffbd6d5),
    'misc': Color(0xffd7d7d6),
  };

  /// 主题配置
  /// 浅色主题
  static CupertinoThemeData ligthTheme = const CupertinoThemeData(
    brightness: Brightness.light,
    barBackgroundColor: navigationBarBackground,
  );

  /// 深色纯黑主题
  static CupertinoThemeData darkPureTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    barBackgroundColor: navigationBarBackground,
  );

  /// 深色灰黑
  static CupertinoThemeData darkGrayTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color.fromARGB(255, 50, 50, 50),
    barBackgroundColor: navigationBarBackgroundGray,
  );

  // cap 颜色
  static const Map catColor2 = {
    'Doujinshi': {'string': 'Doujinshi', 'color': Color(0xfff44336)},
    'Manga': {'string': 'Manga', 'color': Color(0xffff9800)},
    'Artist CG': {'string': 'Artist CG', 'color': Color(0xfffbc02d)},
    'Game CG': {'string': 'Game CG', 'color': Color(0xff4caf50)},
    'Western': {'string': 'Western', 'color': Color(0xff8bc34a)},
    'Non-H': {'string': 'Non-H', 'color': Color(0xff2196f3)},
    'Image Set': {'string': 'Image Set', 'color': Color(0xff3f51b5)},
    'Cosplay': {'string': 'Cosplay', 'color': Color(0xff9c27b0)},
    'Asian Porn': {'string': 'Asian Porn', 'color': Color(0xff9575cd)},
    'Misc': {'string': 'Misc', 'color': Color(0xfff06292)},
    'defaule': {'color': CupertinoColors.systemBackground}
  };

  static const Map catColor = {
    'Doujinshi': CupertinoDynamicColor.withBrightness(
      color: Color(0xfff44336),
      darkColor: Color.fromARGB(255, 145, 49, 39),
    ),
    'Manga': CupertinoDynamicColor.withBrightness(
      color: Color(0xffff9800),
      darkColor: Color.fromARGB(255, 206, 113, 56),
    ),
    'Artist CG': CupertinoDynamicColor.withBrightness(
      color: Color(0xfffbc02d),
      darkColor: Color.fromARGB(255, 202, 145, 58),
    ),
    'Game CG': CupertinoDynamicColor.withBrightness(
      color: Color(0xff4caf50),
      darkColor: Color.fromARGB(255, 115, 145, 112),
    ),
    'Western': CupertinoDynamicColor.withBrightness(
      color: Color(0xff8bc34a),
      darkColor: Color.fromARGB(255, 169, 158, 104),
    ),
    'Non-H': CupertinoDynamicColor.withBrightness(
      color: Color(0xff2196f3),
      darkColor: Color.fromARGB(255, 112, 168, 203),
    ),
    'Image Set': CupertinoDynamicColor.withBrightness(
      color: Color(0xff3f51b5),
      darkColor: Color.fromARGB(255, 59, 93, 157),
    ),
    'Cosplay': CupertinoDynamicColor.withBrightness(
      color: Color(0xff9c27b0),
      darkColor: Color.fromARGB(255, 98, 57, 156),
    ),
    'Asian Porn': CupertinoDynamicColor.withBrightness(
      color: Color(0xff9575cd),
      darkColor: Color.fromARGB(255, 150, 60, 127),
    ),
    'Misc': CupertinoDynamicColor.withBrightness(
      color: Color(0xfff06292),
      darkColor: Color.fromARGB(255, 188, 91, 123),
    ),
    'defaule': CupertinoColors.systemBackground
  };

  /// fav 颜色
  static const Map<String, Color> favColor = <String, Color>{
    '0': Color(0xff5F5F5F),
    '1': Color(0xffDE1C31),
    '2': Color(0xffF97D1C),
    '3': Color(0xffF8B500),
    '4': Color(0xff2BAE85),
    '5': Color(0xff5BAE23),
    '6': Color(0xff22A2C3),
    '7': Color(0xff1661AB),
    '8': Color(0xff9F3EF9),
    '9': Color(0xffEC2D7A),
    'a': Color(0xffB5A4A4),
    'l': Color.fromARGB(255, 169, 158, 104),
  };

  static const CupertinoDynamicColor navigationBarBackground =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'navigationBarBackground',
    color: Color(0xd0f9f9f9),
    darkColor: Color(0xc01b1b1b),
  );

  static const CupertinoDynamicColor navigationBarBackgroundGray =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'navigationBarBackground',
    color: Color(0xd0f9f9f9),
    darkColor: Color(0xd0303030),
  );
}
