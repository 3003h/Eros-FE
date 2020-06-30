import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:flutter/cupertino.dart';

class EHConst {
  // 网页登陆页面
  static const String URL_SIGN_IN =
      "https://forums.e-hentai.org/index.php?act=Login";

  // 参数登陆url
  static const String API_SIGN_IN =
      "https://forums.e-hentai.org/index.php?act=Login&CODE=01";

  static const String CHROME_USER_AGENT =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36";

  static const String CHROME_ACCEPT =
      "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";

  static const String CHROME_ACCEPT_LANGUAGE = "en-US,en;q=0.5";

  static const FAV_ORDER_FAV = 'fs_f';
  static const FAV_ORDER_PUB = 'fs_p';

  static const FONT_FAMILY = '';

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
    {'key': '0', 'desc': 'Favorites 0'},
    {'key': '1', 'desc': 'Favorites 1'},
    {'key': '2', 'desc': 'Favorites 2'},
    {'key': '3', 'desc': 'Favorites 3'},
    {'key': '4', 'desc': 'Favorites 4'},
    {'key': '5', 'desc': 'Favorites 5'},
    {'key': '6', 'desc': 'Favorites 6'},
    {'key': '7', 'desc': 'Favorites 7'},
    {'key': '8', 'desc': 'Favorites 8'},
    {'key': '9', 'desc': 'Favorites 9'},
    {'key': 'a', 'desc': 'Favorites All'},
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
