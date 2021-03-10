import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fehviewer/common/update.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/models/profile.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:fehviewer/utils/https_proxy.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const int kProxyPort = 4041;

final FirebaseAnalytics analytics = FirebaseAnalytics();
final LocalAuthentication localAuth = LocalAuthentication();

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
  cookie: '',
  avatarUrl: '',
  favcat: [],
);

const DownloadTaskInfo kDefDownloadTaskInfo = DownloadTaskInfo(
  tag: '',
  gid: '',
  type: '',
  title: '',
  taskId: '',
  dowmloadType: '',
  status: 0,
  progress: 0,
);

const GalleryPreview kDefGalleryPreview = GalleryPreview(
  isLarge: false,
  isCache: false,
  startPrecache: false,
  ser: -1,
  href: '',
  largeImageUrl: '',
  imgUrl: '',
  height: -1,
  width: -1,
  largeImageHeight: -1,
  largeImageWidth: -1,
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
    downloadLocatino: '',
    downloadOrigImage: false,
  ),
  ehConfig: kDefEhConfig,
  advanceSearch: kDefAdvanceSearch,
);

final Global global = Global();

// 全局配置
// ignore: avoid_classes_with_only_static_members
class Global {
  // 是否第一次打开
  static bool isFirstOpen = false;
  static bool inDebugMode = false;
  static bool isFirstReOpenEhSetting = true;

  static Profile profile = kDefProfile.copyWith(
      ehConfig: kDefEhConfig.copyWith(safeMode: Platform.isIOS));

  // static History history = const History(history: []);
  static List<GalleryCache> galleryCaches = <GalleryCache>[];

  static CookieManager? cookieManager;

  static PersistCookieJar? cookieJar;

  static HttpProxy httpProxy = HttpProxy('localhost', '$kProxyPort');

  static String appSupportPath = '';
  static String appDocPath = '';
  static String tempPath = '';

  static PackageInfo? packageInfo;

  static bool isDBinappSupportPath = false;

  static bool canCheckBiometrics = false;

  User get user => profile.user;
  set user(User val) => profile = profile.copyWith(user: val);

  // init
  static Future<void> init() async {
    // 判断是否debug模式
    inDebugMode = EHUtils().isInDebugMode;

    await FlutterDownloader.initialize(debug: Global.inDebugMode);

    if (!inDebugMode) Logger.level = Level.info;

    canCheckBiometrics = await localAuth.canCheckBiometrics;

    // 代理初始化
    if (Platform.isIOS || Platform.isAndroid) {
      await CustomHttpsProxy.instance.init();
    }

    //statusBar设置为透明，去除半透明遮罩
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    appSupportPath = (await getApplicationSupportDirectory()).path;
    appDocPath = (await getApplicationDocumentsDirectory()).path;
    tempPath = (await getTemporaryDirectory()).path;

    packageInfo = await PackageInfo.fromPlatform();

    logger.d('doc $appDocPath \napps $appSupportPath \ntemp $tempPath');

    // SP初始化
    await StorageUtil.init();

    await GStore.init();

    await vibrateUtil.init();

    _profileInit();

    cookieManager = CookieManager(await Api.cookieJar);
    cookieJar = await Api.cookieJar;

    // 读取设备第一次打开
    isFirstOpen = !StorageUtil().getBool(STORAGE_DEVICE_ALREADY_OPEN_KEY);
    if (isFirstOpen) {
      creatDirs();
      StorageUtil().setBool(STORAGE_DEVICE_ALREADY_OPEN_KEY, true);
    }

    isDBinappSupportPath = StorageUtil().getBool(IS_DB_IN_SUPPORT_DIR);

    // 数据更新
    await dataUpdate();
  }

  static void creatDirs() {
    final Directory downloadDir = Directory(join(appDocPath, 'Download'));
    downloadDir.create();
  }

  /// profile初始化
  static Future<void> _profileInit() async {
    await _checkReset();

    _initProfile();
    // _initHistory();

    if ((profile.dnsConfig.enableCustomHosts ?? false) ||
        (profile.dnsConfig.enableDoH ?? false)) {
      logger.v('${profile.dnsConfig.enableCustomHosts}');
      HttpOverrides.global = httpProxy;
    }
  }

  static void _initProfile() {
    final GStore gStore = Get.find<GStore>();
    profile = gStore.profile;
  }

  // 持久化Profile信息
  static Future<void>? saveProfile() {
    // logger.v(profile.toJson());
    final GStore gStore = Get.find<GStore>();
    gStore.profile = profile;
  }

  static Future<void> _checkReset() async {
    final String cleanVer = StorageUtil().getString(CLEAN_VER) ?? '0';

    if (double.parse(cleanVer) < EHConst.cleanDataVer) {
      logger.d('clean');
      profile = kDefProfile;
      saveProfile();
      StorageUtil().setString(CLEAN_VER, '${EHConst.cleanDataVer}');
    }
  }

  // static void _initHistory() {
  //   final dynamic _history = StorageUtil().getJSON(HISTORY) ?? '{}';
  //   if (_history != null) {
  //     try {
  //       history = History.fromJson(jsonDecode(_history));
  //     } catch (e) {
  //       print('getHistoryFromSP $e');
  //     }
  //   }
  // }
  //
  // static Future<bool>? saveHistory() {
  //   return StorageUtil().setJSON(HISTORY, history);
  // }
}
