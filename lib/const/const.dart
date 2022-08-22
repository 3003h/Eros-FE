import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

final kFilenameFormat =
    GetPlatform.isWindows ? 'yyyy-MM-dd HH_mm_ss' : 'yyyy-MM-dd HH:mm:ss';

enum ListModeEnum {
  list,
  waterfall,
  simpleList,
  waterfallLarge,
  grid,
  global,
  debugSimple,
}

enum TagTranslateDataUpdateMode {
  manual,
  everyStartApp,
}

enum TagIntroImgLv {
  disable,
  nonh,
  r18,
  r18g,
}

enum FavoriteOrder {
  fav,
  posted,
}

enum ViewMode {
  topToBottom,
  LeftToRight,
  rightToLeft,
}

enum CommentSpanType {
  text,
  linkText,
  image,
  linkImage,
}

enum ReadOrientation {
  system,
  auto,
  portraitUp,
  landscapeLeft,
  portraitDown,
  landscapeRight,
}

const Map<ReadOrientation, DeviceOrientation> orientationMap = {
  ReadOrientation.landscapeRight: DeviceOrientation.landscapeRight,
  ReadOrientation.landscapeLeft: DeviceOrientation.landscapeLeft,
  ReadOrientation.portraitUp: DeviceOrientation.portraitUp,
  ReadOrientation.portraitDown: DeviceOrientation.portraitDown,
};

class GetIds {
  static const String SEARCH_INIT_VIEW = 'InitView';
  static const String SEARCH_CLEAR_BTN = 'SEARCH_CLEAR_BTN';
  static const String IMAGE_VIEW_SLIDER = 'PageSlider';
  static const String IMAGE_VIEW = '_buildPhotoViewGallery';
  static const String IMAGE_VIEW_SER = 'GalleryImage_';
  static const String PAGE_VIEW_TOP_COMMENT = 'TopComment';
  static const String PAGE_VIEW_HEADER = 'header';
  static const String PAGE_VIEW_BODY = 'body';
  static const String TAG_ADD_CLEAR_BTN = 'TAG_ADD_CLEAR_BTN';
}

LoadStateChanged defLoadStateChanged = (ExtendedImageState state) {
  switch (state.extendedImageLoadState) {
    case LoadState.loading:
      return Container(
        alignment: Alignment.center,
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGrey5, Get.context!),
        child: const CupertinoActivityIndicator(),
      );
    case LoadState.failed:
      return Container(
        alignment: Alignment.center,
        child: const Icon(
          Icons.error,
          color: Colors.red,
        ),
      );
    default:
      return null;
  }
};

const AdvanceSearch kDefAdvanceSearch = AdvanceSearch(
  searchGalleryName: true,
  searchGalleryTags: true,
  searchGalleryDesc: false,
  searchToreenFilenames: false,
  onlyShowWhithTorrents: false,
  searchLowPowerTags: false,
  searchDownvotedTags: false,
  searchExpunged: false,
  searchWithminRating: false,
  minRating: 2,
  searchBetweenpage: false,
  startPage: '',
  endPage: '',
  disableDFLanguage: false,
  disableDFUploader: false,
  disableDFTags: false,
  favSearchName: true,
  favSearchTags: true,
  favSearchNote: true,
);

const User kDefUser = User(
  username: '',
  avatarUrl: '',
  favcat: [],
);

const DownloadArchiverTaskInfo kDefDownloadTaskInfo = DownloadArchiverTaskInfo(
  tag: '',
  gid: '',
  type: '',
  title: '',
  taskId: '',
  dowmloadType: '',
  status: 0,
  progress: 0,
);

const GalleryImage kDefGalleryImage = GalleryImage(
  largeThumb: false,
  completeCache: false,
  startPrecache: false,
  ser: -1,
  href: '',
  imageUrl: '',
  thumbUrl: '',
  thumbHeight: -1,
  thumbWidth: -1,
  imageHeight: -1,
  imageWidth: -1,
  offSet: -1,
  sourceId: '',
);

const EhConfig kDefEhConfig = EhConfig(
  jpnTitle: false,
  tagTranslat: false,
  tagTranslatVer: '',
  favoritesOrder: '',
  siteEx: false,
  galleryImgBlur: false,
  favPicker: false,
  favLongTap: false,
  lastFavcat: '0',
  lastShowFavcat: 'a',
  lastShowFavTitle: '',
  listMode: '',
  safeMode: false,
  catFilter: 0,
  maxHistory: 100,
  searchBarComp: true,
  pureDarkTheme: false,
  viewModel: '',
  clipboardLink: false,
  commentTrans: false,
  autoLockTimeOut: -1,
  showPageInterval: true,
  orientation: '',
  vibrate: true,
  tagIntroImgLv: '',
  toplist: '15',
);

const Profile kDefProfile = Profile(
  user: kDefUser,
  locale: '',
  lastLogin: '',
  theme: '',
  searchText: [],
  localFav: LocalFav(gallerys: []),
  enableAdvanceSearch: false,
  autoLock: AutoLock(lastLeaveTime: -1, isLocking: false),
  dnsConfig: DnsConfig(
    enableDoH: false,
    enableCustomHosts: false,
    enableDomainFronting: false,
    hosts: [],
    dohCache: [],
  ),
  downloadConfig: DownloadConfig(
    preloadImage: 5,
    multiDownload: -1,
    downloadLocation: '',
    downloadOrigImage: false,
  ),
  ehConfig: kDefEhConfig,
  advanceSearch: kDefAdvanceSearch,
  favConfig: FavConfig(lastIndex: 0),
);

final RegExp regGalleryUrl =
    RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
final RegExp regGalleryPageUrl =
    RegExp(r'https?://e[-x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
final RegExp regGalleryMpvPageUrl =
    RegExp(r'https?://e[-x]hentai.org/mpv/([0-9]+)/([0-9a-z]+)/#page(\d+)');
final RegExp regExpMpvThumbName = RegExp(r'[0-9a-f]{40}-(\d+)-(\d+)-(\d+)');

// ignore: avoid_classes_with_only_static_members
class EHConst {
  // 网页登陆页面
  static const String URL_SIGN_IN =
      'https://forums.e-hentai.org/index.php?act=Login';

  // 参数登陆url
  static const String API_SIGN_IN =
      'https://forums.e-hentai.org/index.php?act=Login&CODE=01';

  static const String CHROME_USER_AGENT =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.54 Safari/537.36 Edg/95.0.1020.30';

  static const String CHROME_ACCEPT =
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9';

  static const String CHROME_ACCEPT_LANGUAGE =
      'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6';

  static const String FAV_ORDER_FAV = 'fs_f';
  static const String FAV_ORDER_POSTED = 'fs_p';

  static const List<String> FONT_FAMILY_FB = ['PingFang SC', 'Heiti SC'];

  static const String EH_BASE_URL = 'https://e-hentai.org';
  static const String EX_BASE_URL = 'https://exhentai.org';

  static const String EH_BASE_HOST = 'e-hentai.org';
  static const String EX_BASE_HOST = 'exhentai.org';

  static const String EH_TORRENT_URL = 'https://ehtracker.org/get';
  static const String EX_TORRENT_URL = 'https://exhentai.org/torrent';

  static const String DB_NAME = 'feh.db';

  static const int exMaxConnectionsPerHost = 4;

  static String getBaseSite([bool isEx = false]) =>
      isEx ? EX_BASE_URL : EH_BASE_URL;

  static String getBaseHost([bool isEx = false]) =>
      isEx ? EX_BASE_HOST : EH_BASE_HOST;

  static String get torrentBaseUrl =>
      (Get.find<EhConfigService>().isSiteEx.value)
          ? EX_TORRENT_URL
          : EH_TORRENT_URL;

  // 瀑布流视图参数
  static const double waterfallFlowCrossAxisSpacing = 4.0;
  static const double waterfallFlowMainAxisSpacing = 4.0;
  static const double waterfallFlowMaxCrossAxisExtent = 150.0;
  static const double waterfallFlowMaxCrossAxisExtentTablet = 220.0;

  // 瀑布流视图参数 large
  static const double waterfallFlowLargeCrossAxisSpacing = 12.0;
  static const double waterfallFlowLargeMainAxisSpacing = 12.0;
  static const double waterfallFlowLargeMaxCrossAxisExtent = 220.0;

  // Grid视图参数
  static const double gridCrossAxisSpacing = 6.0;
  static const double gridMainAxisSpacing = 6.0;
  static const double gridMaxCrossAxisExtent = 150.0;
  static const double gridChildAspectRatio = 1 / 1.8;

  static List<int> historyMax = <int>[50, 100, 300, 0];

  static List<int> preloadImage = <int>[
    if (Global.inDebugMode) 0,
    1,
    3,
    5,
    7,
  ];

  static List<int> tagLimit = <int>[
    -1,
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ];

  static List<int> multiDownload = <int>[
    1,
    3,
    5,
    7,
    9,
    11,
    if (Global.inDebugMode) 100,
  ];

  static int cleanDataVer = 1;

  static List<int> autoLockTime = <int>[
    -1,
    0,
    if (Global.inDebugMode) 10,
    30,
    60 * 1,
    60 * 5,
    60 * 10,
    60 * 30,
    60 * 60,
    60 * 60 * 5,
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
    'uploader': '上传者',
    'other': '其他',
    'mixed': '混杂',
    'cosplayer': '扮演者',
    'temp': '临时',
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

  static const Map<String, String> favCat = {
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
  ];

  static const Map<String, String> prefixToNameSpaceMap = {
    'a': 'artist',
    'c': 'character',
    'f': 'female',
    'g': 'group',
    'l': 'language',
    'm': 'male',
    'p': 'parody',
    'r': 'reclass',
    'o': 'other',
    'x': 'mixed',
    'cos': 'cosplayer',
    'misc': 'misc',
  };

  /// iso936语言对应缩写
  static const Map<String, String> iso936 = <String, String>{
    'japanese': 'JP',
    'english': 'EN',
    'chinese': 'ZH',
    'dutch': 'NL',
    'french': 'FR',
    'german': 'DE',
    'hungarian': 'HU',
    'italian': 'IT',
    'korean': 'KR',
    'polish': 'PL',
    'portuguese': 'PT',
    'russian': 'RU',
    'spanish': 'ES',
    'thai': 'TH',
    'vietnamese': 'VI',
  };

  static final List<String> fontFamilyFallback = [
    'miui',
    // if (GetPlatform.isAndroid) 'SourceHanSansSC',
    'sans-serif',
  ];
  static const List<String> monoFontFamilyFallback = [
    'monaco',
    'monospace',
    'Menlo',
    'Courier New',
  ];

  static const emojiFontFamily = 'AppleEmoji';

  static const List<IconData> fontAwesomeIconSicons = [
    FontAwesomeIcons.solidHeart,
    FontAwesomeIcons.heart,
    FontAwesomeIcons.fireFlameCurved,
    FontAwesomeIcons.fire,
    FontAwesomeIcons.poop,
    FontAwesomeIcons.skull,
    FontAwesomeIcons.wheelchairMove,
    FontAwesomeIcons.earthAmericas,
    FontAwesomeIcons.maskFace,
    FontAwesomeIcons.appleWhole,
    FontAwesomeIcons.binoculars,
    FontAwesomeIcons.boxesStacked,
    FontAwesomeIcons.bottleDroplet,
    FontAwesomeIcons.bus,
    FontAwesomeIcons.brush,
    FontAwesomeIcons.chessQueen,
    FontAwesomeIcons.church,
    FontAwesomeIcons.crow,
    FontAwesomeIcons.democrat,
    FontAwesomeIcons.dog,
    FontAwesomeIcons.dove,
    FontAwesomeIcons.eye,
    FontAwesomeIcons.glasses,
    FontAwesomeIcons.leaf,
    FontAwesomeIcons.mask,
    FontAwesomeIcons.moon,
    FontAwesomeIcons.paperPlane,
    FontAwesomeIcons.plane,
    FontAwesomeIcons.seedling,
    FontAwesomeIcons.shirt,
    FontAwesomeIcons.spider,
    FontAwesomeIcons.wallet,
    FontAwesomeIcons.a,
    FontAwesomeIcons.b,
    FontAwesomeIcons.c,
    FontAwesomeIcons.d,
    FontAwesomeIcons.e,
    FontAwesomeIcons.f,
    FontAwesomeIcons.g,
    FontAwesomeIcons.h,
    FontAwesomeIcons.i,
    FontAwesomeIcons.j,
    FontAwesomeIcons.k,
    FontAwesomeIcons.l,
    FontAwesomeIcons.m,
    FontAwesomeIcons.n,
    FontAwesomeIcons.o,
    FontAwesomeIcons.p,
    FontAwesomeIcons.q,
    FontAwesomeIcons.r,
    FontAwesomeIcons.s,
    FontAwesomeIcons.t,
    FontAwesomeIcons.u,
    FontAwesomeIcons.v,
    FontAwesomeIcons.w,
    FontAwesomeIcons.x,
    FontAwesomeIcons.y,
    FontAwesomeIcons.z,
    FontAwesomeIcons.zero,
    FontAwesomeIcons.one,
    FontAwesomeIcons.two,
    FontAwesomeIcons.tree,
    FontAwesomeIcons.four,
    FontAwesomeIcons.five,
    FontAwesomeIcons.six,
    FontAwesomeIcons.seven,
    FontAwesomeIcons.eight,
    FontAwesomeIcons.nine,
  ];

  static const List<int> invList = [
    500,
    1000,
    1500,
    2000,
    2500,
    3000,
    3500,
    4000,
    4500,
    5000,
    5500,
    6000,
    6500,
    7000,
    7500,
    8000,
    8500,
    9000,
    9500,
    10000,
  ];

  static const Map<String, List<String>> internalHosts = {
    'e-hentai.org': [
      '104.20.134.21',
      '172.67.0.127',
      '104.20.135.21',
    ],
    // 'api.e-hentai.org': ['37.48.89.16'],
    'api.e-hentai.org': [
      '178.162.147.246',
      '37.48.89.16',
      '178.162.139.18',
      '81.171.10.55',
    ],
    'forums.e-hentai.org': [
      '104.20.135.21',
      '172.67.0.127',
      '104.20.134.21',
    ],
    'ehgt.org': [
      '178.162.140.212',
      '178.162.139.24',
      '37.48.89.44',
      '81.171.10.48',
    ],
    'exhentai.org': [
      '178.175.129.254',
      '178.175.129.252',
      '178.175.132.20',
      '178.175.132.22',
      '178.175.128.252',
      '178.175.128.254',
    ],
    'api.exhentai.org': [
      '178.175.128.252',
      '178.175.129.252',
      '178.175.132.20',
    ],
  };
}
