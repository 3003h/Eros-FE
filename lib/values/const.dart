import 'package:FEhViewer/fehviewer/model/favorite.dart';
import 'package:FEhViewer/fehviewer/route/routes.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EHConst {
  static const List settingList = [
    {
      "name": "eh",
      "title": "EH设置",
      "icon": CupertinoIcons.book_solid,
      "route": EHRoutes.ehSetting
    },
    {
      "name": "myTag",
      "title": "我的标签",
      "icon": CupertinoIcons.tags_solid,
      "route": EHRoutes.ehSetting
    },
    {
      "name": "download",
      "title": "下载设置",
      "icon": EHCupertinoIcons.download,
      "route": EHRoutes.ehSetting
    },
    {
      "name": "advans",
      "title": "高级设置",
      "icon": CupertinoIcons.gear_big,
      "route": EHRoutes.ehSetting
    },
    {
      "name": "about",
      "title": "关于",
      "icon": EHCupertinoIcons.info_solid,
      "route": EHRoutes.ehSetting
    },
  ];

  static const urls = {
    "default": "https://exhentai.org/",
    "homepage": "https://exhentai.org/",
    "watched": "https://exhentai.org/watched",
    "popular": "https://exhentai.org/popular",
    "favorites": "https://exhentai.org/favorites.php",
    "config": "https://exhentai.org/uconfig.php",
    "downloads": "downloads://index?page=0",
    "login": "https://forums.e-hentai.org/index.php?act=Login&CODE=01",
    "api": "https://exhentai.org/api.php",
    "gallerypopups": "https://exhentai.org/gallerypopups.php"
  };

  static const List favList = [
    {'name': 'fav0', 'desc': 'Favorites 0'},
    {'name': 'fav1', 'desc': 'Favorites 1'},
    {'name': 'fav2', 'desc': 'Favorites 2'},
    {'name': 'fav3', 'desc': 'Favorites 3'},
    {'name': 'fav4', 'desc': 'Favorites 4'},
    {'name': 'fav5', 'desc': 'Favorites 5'},
    {'name': 'fav6', 'desc': 'Favorites 6'},
    {'name': 'fav7', 'desc': 'Favorites 7'},
    {'name': 'fav8', 'desc': 'Favorites 8'},
    {'name': 'fav9', 'desc': 'Favorites 9'},
    {'name': 'fava', 'desc': 'Favorites All'},
  ];

  static const Map prefixToNameSpaceMap = {
    'a:': 'artist',
    'c:': 'character',
    'f:': 'female',
    'g:': 'group',
    'l:': 'language',
    'm:': 'male',
    'p:': 'parody',
    'r:': 'reclass',
  };
}
