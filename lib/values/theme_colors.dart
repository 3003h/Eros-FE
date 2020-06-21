import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeColors {
  static const Color colorPrimary = Color(0xff4caf50);
  static const Color colorPrimaryDark = Color(0xff388E3C);
  static const Color colorAccent = Color(0xff8BC34A);
  static const Color colorPrimaryLight = Color(0xffC8E6C9);

  static const Color primaryText = Color(0xff212121);
  static const Color secondaryText = Color(0xff757575);

  static const Color dividerColor = Color(0xffBDBDBD);

  static const Color bg = Color(0xffF9F9F9);
  static const Color color_F9F9F9 = Color(0xffF9F9F9);

  static const Color color_999 = Color(0xff999999);
  static const Color color_666 = Color(0xff666666);

  static const Color color_f3f3f3 = Color(0xfff3f3f3);
  static const Color color_f1f1f1 = Color(0xfff1f1f1);
  static const Color color_fff = Color(0xffffffff);

  // tap 颜色
  static const Map nameColor2 = {
    "Doujinshi": {"string": "Doujinshi", "color": Color(0xff9E2720)},
    "Manga": {"string": "Manga", "color": Color(0xffDB6C24)},
    "Artist CG": {"string": "Artist CG", "color": Color(0xffD38F1D)},
    "Game CG": {"string": "Game CG", "color": Color(0xff617C63)},
    "Western": {"string": "Western", "color": Color(0xffAB9F60)},
    "Non-H": {"string": "Non-H", "color": Color(0xff5FA9CF)},
    "Image Set": {"string": "Image Set", "color": Color(0xff325CA2)},
    "Cosplay": {"string": "Cosplay", "color": Color(0xff6A32A2)},
    "Asian Porn": {"string": "Asian Porn", "color": Color(0xffA23282)},
    "Misc": {"string": "Misc", "color": Color(0xff777777)},
    "defaule": {"color": CupertinoColors.systemBackground}
  };

  // tap 颜色
  static const Map nameColor = {
    "Doujinshi": {"string": "Doujinshi", "color": Color(0xfff44336)},
    "Manga": {"string": "Manga", "color": Color(0xffff9800)},
    "Artist CG": {"string": "Artist CG", "color": Color(0xfffbc02d)},
    "Game CG": {"string": "Game CG", "color": Color(0xff4caf50)},
    "Western": {"string": "Western", "color": Color(0xff8bc34a)},
    "Non-H": {"string": "Non-H", "color": Color(0xff2196f3)},
    "Image Set": {"string": "Image Set", "color": Color(0xff3f51b5)},
    "Cosplay": {"string": "Cosplay", "color": Color(0xff9c27b0)},
    "Asian Porn": {"string": "Asian Porn", "color": Color(0xff9575cd)},
    "Misc": {"string": "Misc", "color": Color(0xfff06292)},
    "defaule": {"color": CupertinoColors.systemBackground}
  };

  /// fav 颜色
  static const Map favColor = {
    "0": Color(0xff777777),
    "1": Color(0xff9E2720),
    "2": Color(0xffDB6C24),
    "3": Color(0xffD38F1D),
    "4": Color(0xff617C63),
    "5": Color(0xff325CA2),
    "6": Color(0xff6A32A2),
    "7": Color(0xffA23282),
    "8": Color(0xff5FA9CF),
    "9": Color(0xffAB9F60),
    "a": Color(0xff000000),
  };

  static const Map themeColor = {
    "green": {
      //green
      "primaryColor": Color(0xff4caf50),
      "primaryColorDark": Color(0xff388E3C),
      "colorAccent": Color(0xff8BC34A),
      "colorPrimaryLight": Color(0xffC8E6C9),
    },
    "red": {
      //red
      "primaryColor": Color(0xffF44336),
      "primaryColorDark": Color(0xffD32F2F),
      "colorAccent": Color(0xffFF5252),
      "colorPrimaryLight": Color(0xffFFCDD2),
    },
    "blue": {
      //blue
      "primaryColor": Color(0xff2196F3),
      "primaryColorDark": Color(0xff1976D2),
      "colorAccent": Color(0xff448AFF),
      "colorPrimaryLight": Color(0xffBBDEFB),
    },
    "pink": {
      //pink
      "primaryColor": Color(0xffE91E63),
      "primaryColorDark": Color(0xffC2185B),
      "colorAccent": Color(0xffFF4081),
      "colorPrimaryLight": Color(0xffF8BBD0),
    },
    "purple": {
      //purple
      "primaryColor": Color(0xff673AB7),
      "primaryColorDark": Color(0xff512DA8),
      "colorAccent": Color(0xff7C4DFF),
      "colorPrimaryLight": Color(0xffD1C4E9),
    },
    "grey": {
      //grey
      "primaryColor": Color(0xff9E9E9E),
      "primaryColorDark": Color(0xff616161),
      "colorAccent": Color(0xff9E9E9E),
      "colorPrimaryLight": Color(0xffF5F5F5),
    },
    "black": {
      //black
      "primaryColor": Color(0xff333333),
      "primaryColorDark": Color(0xff000000),
      "colorAccent": Color(0xff666666),
      "colorPrimaryLight": Color(0xff999999),
    },
  };
}
