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

  static const FONT_FAMILY_FB = ["PingFang SC", "Heiti SC"];

  static const EH_BASE_URL = 'https://e-hentai.org';
  static const EX_BASE_URL = 'https://exhentai.org';

  static getBaseSite(bool isEx) => isEx ? EX_BASE_URL : EH_BASE_URL;

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

  static const translateTagType = {
    "artist": "作者",
    "female": "女性",
    "male": "男性",
    "parody": "原作",
    "character": "角色",
    "group": "团队",
    "language": "语言",
    "reclass": "归类",
    "misc": "杂项"
  };

  static const tagColorTagType = {
    "artist": Color(0xffE6D6D0),
    "female": Color(0xffFAE0D4),
    "male": Color(0xfff9eed8),
    "parody": Color(0xffd8e6e2),
    "character": Color(0xffd5e4f7),
    "group": Color(0xffdfd6f7),
    "language": Color(0xfff5d5e5),
    "reclass": Color(0xfffbd6d5),
    "misc": Color(0xffd7d7d6),
  };

  static const sumCats = 1023;
  static const cats = {
    "Doujinshi": 2,
    "Manga": 4,
    "Artist CG": 8,
    "Game CG": 16,
    "Western": 512,
    "Non-H": 256,
    "Image Set": 32,
    "Cosplay": 64,
    "Asian Porn": 128,
    "Misc": 1,
  };

  static const Map favCat = {
    '#000': '0',
    '#f00': '1',
    '#fa0': '2',
    '#dd0': '3',
    '#080': '4',
    '#9f4': '5',
    '#4bf': '6',
    '#00f': '7',
    '#508': '8',
    '#e8e': '9',
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
