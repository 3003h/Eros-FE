// 列表模式 瀑布流模式
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:get/get.dart';

enum ListModeEnum {
  list,
  waterfall,
  simpleList,
}

enum FavoriteOrder {
  fav,
  posted,
}

enum ViewMode {
  vertical,
  horizontalLeft,
  horizontalRight,
}

// ignore: avoid_classes_with_only_static_members
class EHConst {
  // 网页登陆页面
  static const String URL_SIGN_IN =
      'https://forums.e-hentai.org/index.php?act=Login';

  // 参数登陆url
  static const String API_SIGN_IN =
      'https://forums.e-hentai.org/index.php?act=Login&CODE=01';

  static const String CHROME_USER_AGENT =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36';

  static const String CHROME_ACCEPT =
      'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';

  static const String CHROME_ACCEPT_LANGUAGE = 'en-US,en;q=0.5';

  static const String FAV_ORDER_FAV = 'fs_f';
  static const String FAV_ORDER_POSTED = 'fs_p';

  static const List<String> FONT_FAMILY_FB = ['PingFang SC', 'Heiti SC'];

  static const String EH_BASE_URL = 'https://e-hentai.org';
  static const String EX_BASE_URL = 'https://exhentai.org';

  static const String EH_TORRENT_URL = 'https://ehtracker.org/get';
  static const String EX_TORRENT_URL = 'https://exhentai.org/torrent';

  static String getBaseSite([bool isEx = false]) =>
      isEx ? EX_BASE_URL : EH_BASE_URL;

  static String get torrentBaseUrl =>
      (Get.find<EhConfigService>().isSiteEx.value ?? false)
          ? EX_TORRENT_URL
          : EH_TORRENT_URL;

  // 瀑布流视图参数
  static const double waterfallFlowCrossAxisSpacing = 4.0;
  static const double waterfallFlowMainAxisSpacing = 4.0;
  static const double waterfallFlowMaxCrossAxisExtent = 150.0;

  static List<int> historyMax = <int>[50, 100, 300, 0];

  static List<int> preloadImage = <int>[
    if (Global.inDebugMode) 0,
    3,
    5,
    7,
    9,
    11,
    13,
    17,
  ];

  static const Map<FavoriteOrder, String> favoriteOrder =
      <FavoriteOrder, String>{
    FavoriteOrder.fav: FAV_ORDER_FAV,
    FavoriteOrder.posted: FAV_ORDER_POSTED,
  };

  static const Map<String, String> translateTagType = {
    'artist': '作者',
    'female': '女性',
    'male': '男性',
    'parody': '原作',
    'character': '角色',
    'group': '团队',
    'language': '语言',
    'reclass': '归类',
    'misc': '杂项',
    'uploader': '上传者'
  };

  static const int sumCats = 1023;
  static const Map<String, int> cats = {
    'Doujinshi': 2,
    'Manga': 4,
    'Artist CG': 8,
    'Game CG': 16,
    'Western': 512,
    'Non-H': 256,
    'Image Set': 32,
    'Cosplay': 64,
    'Asian Porn': 128,
    'Misc': 1,
  };

  static List<String> catList = <String>[
    'Misc',
    'Doujinshi',
    'Manga',
    'Artist CG',
    'Game CG',
    'Image Set',
    'Cosplay',
    'Asian Porn',
    'Non-H',
    'Western',
  ];

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

  static const List<Map<String, String>> favList = <Map<String, String>>[
    {'favcat': '0', 'desc': 'Favorites 0'},
    {'favcat': '1', 'desc': 'Favorites 1'},
    {'favcat': '2', 'desc': 'Favorites 2'},
    {'favcat': '3', 'desc': 'Favorites 3'},
    {'favcat': '4', 'desc': 'Favorites 4'},
    {'favcat': '5', 'desc': 'Favorites 5'},
    {'favcat': '6', 'desc': 'Favorites 6'},
    {'favcat': '7', 'desc': 'Favorites 7'},
    {'favcat': '8', 'desc': 'Favorites 8'},
    {'favcat': '9', 'desc': 'Favorites 9'},
    {'favcat': 'l', 'desc': 'Local Favorites'},
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

  /// iso936语言对应缩写
  static const Map<String, String> iso936 = <String, String>{
    'Japanese': 'JP',
    'English': 'EN',
    'Chinese': 'ZH',
    'Dutch': 'NL',
    'French': 'FR',
    'German': 'DE',
    'Hungarian': 'HU',
    'Italian': 'IT',
    'Korean': 'KR',
    'Polish': 'PL',
    'Portuguese': 'PT',
    'Russian': 'RU',
    'Spanish': 'ES',
    'Thai': 'TH',
    'Vietnamese': 'VI',
  };
}
