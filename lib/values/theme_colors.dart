import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeColors {
  // tap 颜色
  static const Map nameColor = {
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

  /// fav 颜色
  static const Map favColor = {
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
  };

  static const CupertinoDynamicColor navigationBarBackground =
      CupertinoDynamicColor(
    debugLabel: 'navigationBarBackground',
    color: Color(0xc0f9f9f9),
    darkColor: Color(0xc01b1b1b),
    highContrastColor: Color(0xc0f9f9f9),
    darkHighContrastColor: Color(0xc01b1b1b),
    elevatedColor: Color(0xc0f9f9f9),
    darkElevatedColor: Color(0xc01b1b1b),
    highContrastElevatedColor: Color(0xc0f9f9f9),
    darkHighContrastElevatedColor: Color(0xc01b1b1b),
  );
}
