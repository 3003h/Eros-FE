import 'package:fehviewer/common/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'const.dart';

final ehTextTheme = const CupertinoTextThemeData().copyWith(
    textStyle: const CupertinoTextThemeData().textStyle.copyWith(
          fontFamilyFallback: EHConst.fontFamilyFallback,
        ));

enum ThemesModeEnum {
  system,
  ligthMode,
  darkMode,
}

class CustTheme {
  late CupertinoThemeData themeData;
}

class EhDynamicColors {
  static const EhDynamicColor textFieldBackground = EhDynamicColor(
    color: Color.fromARGB(255, 239, 239, 240),
    darkColor: Color.fromARGB(255, 28, 28, 31),
    darkGrayColor: Color.fromARGB(255, 47, 47, 47),
  );

  static const EhDynamicColor commentTextFieldBackground = EhDynamicColor(
    color: Color.fromARGB(255, 233, 233, 233),
    darkColor: Color.fromARGB(255, 28, 28, 31),
    darkGrayColor: Color.fromARGB(255, 47, 47, 47),
  );

  static const EhDynamicColor commentReplyBackground = EhDynamicColor(
    color: Color.fromARGB(255, 253, 253, 253),
    darkColor: Color.fromARGB(255, 0, 0, 0),
    darkGrayColor: Color.fromARGB(255, 28, 28, 28),
  );

  static const EhDynamicColor commentBackground = EhDynamicColor(
    color: Color.fromARGB(255, 242, 242, 247),
    darkColor: Color.fromARGB(255, 20, 20, 20),
    darkGrayColor: Color.fromARGB(255, 40, 40, 40),
  );

  static const EhDynamicColor favnoteTextFieldBackground = EhDynamicColor(
    color: Color.fromARGB(255, 250, 250, 250),
    darkColor: Color.fromARGB(255, 28, 28, 31),
    darkGrayColor: Color.fromARGB(255, 47, 47, 47),
  );

  static const EhDynamicColor itemBackground = EhDynamicColor(
    color: Color.fromARGB(255, 255, 255, 255),
    darkColor: Color.fromARGB(255, 30, 30, 30),
    darkGrayColor: Color.fromARGB(255, 32, 32, 32),
  );

  static const EhDynamicColor commitIcon = EhDynamicColor(
    color: Color.fromARGB(255, 140, 140, 142),
    darkColor: Color.fromARGB(255, 132, 132, 137),
    darkGrayColor: Color.fromARGB(255, 132, 132, 137),
  );
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
    darkColor: Color.fromARGB(255, 40, 40, 40),
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
    color: CupertinoColors.label,
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

  static const Color dialogColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xCCF2F2F2),
    darkColor: Color(0xBF1E1E1E),
  );

  static List<Color> get tagColorList => tagColorTagType.values.toList();

  /// 标签总分类颜色
  static const Map<String, Color> tagColorTagType = <String, Color>{
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
    'temp': CupertinoDynamicColor.withBrightness(
      color: Color(0xffd7d7d6),
      darkColor: Color.fromARGB(255, 99, 102, 106),
    ),
    'other': CupertinoDynamicColor.withBrightness(
      color: Color(0xfffbd6d5),
      darkColor: Color.fromARGB(255, 146, 85, 84),
    ),
    'cosplayer': CupertinoDynamicColor.withBrightness(
      color: Color(0xfff5d5e5),
      darkColor: Color.fromARGB(255, 127, 74, 107),
    ),
  };

  /// 主题配置
  /// 浅色主题
  static CupertinoThemeData ligthTheme = CupertinoThemeData(
    brightness: Brightness.light,
    barBackgroundColor: navigationBarBackground,
    textTheme: ehTextTheme,
    // scaffoldBackgroundColor: CupertinoColors.secondarySystemBackground,
  );

  /// 浅色主题
  static CupertinoThemeData ligthThemeSecondary = CupertinoThemeData(
    brightness: Brightness.light,
    barBackgroundColor: navigationBarBackground,
    scaffoldBackgroundColor: CupertinoColors.secondarySystemBackground,
    textTheme: ehTextTheme,
  );

  /// 深色纯黑主题
  static CupertinoThemeData darkPureTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    barBackgroundColor: navigationBarBackground,
    // scaffoldBackgroundColor: CupertinoColors.secondarySystemBackground,
    textTheme: ehTextTheme,
  );

  /// 深色灰黑
  static CupertinoThemeData darkGrayTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20),
    barBackgroundColor: navigationBarBackgroundGray,
    textTheme: ehTextTheme,
  );

  static List<Color> get catColorList => catColor.entries
      .where((e) => e.key != 'default')
      .map((e) => e.value)
      .toList();

  // 画廊类型主题色
  static const Map<String, Color> catColor = <String, Color>{
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
    'Private': CupertinoDynamicColor.withBrightness(
      color: Color.fromARGB(255, 48, 48, 46),
      darkColor: Color.fromARGB(255, 70, 70, 73),
    ),
    'default': CupertinoColors.systemBackground
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
    color: Color.fromARGB(200, 249, 249, 249),
    darkColor: Color.fromARGB(200, 20, 20, 20),
  );

  static const CupertinoDynamicColor navigationBarBackgroundGray =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'navigationBarBackgroundGray',
    // color: Color.fromARGB(230, 35, 35, 35),
    color: Color.fromARGB(200, 249, 249, 249),
    darkColor: Color.fromARGB(200, 25, 25, 25),
    // color: Color.fromARGB(222, 186, 27, 27),
    // darkColor: Color.fromARGB(230, 21, 212, 75),
  );

  static const Map<String, Color> colorRatingMap = <String, Color>{
    'ir': Color.fromARGB(255, 255, 150, 46),
    'ir irr': Color.fromARGB(255, 255, 100, 120),
    'ir irg': Color.fromARGB(255, 50, 200, 50),
    'ir irb': Color.fromARGB(255, 126, 120, 255),
  };

  // tup
  static const CupertinoDynamicColor tagUpColor =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'tagUpColor',
    color: Color.fromARGB(255, 32, 186, 64),
    darkColor: Color.fromARGB(255, 110, 210, 110),
  );

  static const CupertinoDynamicColor tagDownColor =
      CupertinoDynamicColor.withBrightness(
    debugLabel: 'tagDownColor',
    color: Color.fromARGB(255, 250, 70, 70),
    darkColor: Color.fromARGB(255, 250, 107, 125),
  );
}
