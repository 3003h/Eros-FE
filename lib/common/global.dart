import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:device_info/device_info.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/app_dio/http_config.dart';
import 'package:fehviewer/store/floor/database.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/store/hive/hive.dart';
import 'package:fehviewer/utils/http_override.dart';
import 'package:fehviewer/utils/optional.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:system_proxy/system_proxy.dart';

const int kProxyPort = 4041;

final LocalAuthentication localAuth = LocalAuthentication();
DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

final HiveHelper hiveHelper = HiveHelper();

final Global global = Global();

var globalDioConfig = ehDioConfig;

void switchGlobalDioConfig(bool isSiteEx) {
  DioHttpConfig dioConfig = isSiteEx ? exDioConfig : ehDioConfig;
  globalDioConfig = globalDioConfig.copyWith(
    baseUrl: dioConfig.baseUrl,
    receiveTimeout: dioConfig.receiveTimeout,
    connectTimeout: dioConfig.connectTimeout,
    maxConnectionsPerHost: dioConfig.maxConnectionsPerHost,
  );
}

final DioHttpConfig ehDioConfig = DioHttpConfig(
  baseUrl: EHConst.EH_BASE_URL,
  cookiesPath: Global.appSupportPath,
  connectTimeout: 10000,
  sendTimeout: 8000,
  receiveTimeout: 20000,
  maxConnectionsPerHost: null,
);

final DioHttpConfig exDioConfig = DioHttpConfig(
  baseUrl: EHConst.EX_BASE_URL,
  cookiesPath: Global.appSupportPath,
  connectTimeout: 15000,
  sendTimeout: 8000,
  receiveTimeout: 25000,
  maxConnectionsPerHost: EHConst.exMaxConnectionsPerHost,
);

final EhHttpOverrides ehHttpOverrides = EhHttpOverrides();

// 全局配置
// ignore: avoid_classes_with_only_static_members
class Global {
  // 是否第一次打开
  static bool isFirstOpen = false;
  static bool inDebugMode = false;
  static bool isFirstReOpenEhSetting = true;

  static bool forceRefreshUconfig = true;

  // static Profile profile = kDefProfile.copyWith(
  //     ehConfig: kDefEhConfig.copyWith(safeMode: Platform.isIOS));
  static Profile profile = kDefProfile.copyWith(ehConfig: kDefEhConfig);

  static List<GalleryCache> galleryCaches = <GalleryCache>[];

  static late CookieManager cookieManager;

  static late PersistCookieJar cookieJar;

  // static HttpProxy httpProxy = HttpProxy('localhost', '$kProxyPort');
  // static DFHttpOverrides dfHttpOverrides = DFHttpOverrides();

  static String appSupportPath = '';
  static String appDocPath = '';
  static String tempPath = '';
  static late String extStorePath;
  static String dbPath = '';

  static late PackageInfo packageInfo;

  static bool isDBinappSupportPath = false;

  static bool canCheckBiometrics = false;

  User get user => profile.user;
  set user(User val) => profile = profile.copyWith(user: val);

  static Future<EhDatabase> getDatabase({String? path}) async {
    return await $FloorEhDatabase
        .databaseBuilder(path ?? Global.dbPath)
        .addMigrations(ehMigrations)
        .build();
  }

  // init
  static Future<void> init() async {
    // 判断是否debug模式
    inDebugMode = kDebugMode;

    if (GetPlatform.isMobile) {
      await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
    }

    if (GetPlatform.isMobile) {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    }

    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    if (GetPlatform.isMobile) {
      // the systemProxy value likes:  {port: 8899, host: 127.0.0.1}
      Map<String, String>? systemProxy = await SystemProxy.getProxySettings();
      if (systemProxy != null) {
        globalDioConfig = globalDioConfig.copyWith(
          proxy: 'PROXY ${systemProxy['host']}:${systemProxy['port']}',
        );
        print('systemProxy $systemProxy');
      }
    }

    //statusBar设置为透明，去除半透明遮罩
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));

    appSupportPath = (await getApplicationSupportDirectory()).path;
    appDocPath = (await getApplicationDocumentsDirectory()).path;
    tempPath = (await getTemporaryDirectory()).path;
    extStorePath = Platform.isAndroid || Platform.isFuchsia
        ? (await getExternalStorageDirectory())?.path ?? ''
        : '';

    if (!GetPlatform.isWindows) {
      packageInfo = await PackageInfo.fromPlatform();
    }

    initLogger();
    if (!inDebugMode) {
      Logger.level = Level.info;
      initLogger();
    }

    // 代理初始化
    // if (Platform.isIOS || Platform.isAndroid) {
    //   await CustomHttpsProxy.instance.init();
    // }

    // logger.v('doc $appDocPath \napps $appSupportPath \ntemp $tempPath');

    dbPath = path.join(Global.appSupportPath, EHConst.DB_NAME);

    // SP初始化
    await StorageUtil.init();

    await GStore.init();

    await HiveHelper.init();

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
    // await dataUpdate();

    initImageHttpClient();
  }

  static void creatDirs() {
    final Directory downloadDir = Directory(path.join(appDocPath, 'Download'));
    downloadDir.create();
  }

  /// profile初始化
  static Future<void> _profileInit() async {
    _checkReset();

    _initProfile();

    if (profile.dnsConfig.enableDomainFronting ?? false) {
      logger.d('enableDomainFronting');
      HttpOverrides.global = ehHttpOverrides..skipCertificateCheck = true;
    }
  }

  static void _initProfile() {
    final GStore gStore = Get.find<GStore>();
    // logger.v('profile\n${jsonEncode(gStore.profile.webdav)}');
    profile = gStore.profile;
  }

  // 持久化Profile信息
  static void saveProfile() {
    // logger.d(profile.toJson());
    final GStore gStore = Get.find<GStore>();
    gStore.profile = profile;
  }

  static void _checkReset() {
    final String cleanVer = StorageUtil().getString(CLEAN_VER) ?? '0';

    if (double.parse(cleanVer) < EHConst.cleanDataVer) {
      logger.d('clean');
      profile = kDefProfile;
      saveProfile();
      StorageUtil().setString(CLEAN_VER, '${EHConst.cleanDataVer}');
    }
  }

  static void initImageHttpClient({int? maxConnectionsPerHost}) {
    final HttpClient eClient =
        ExtendedNetworkImageProvider.httpClient as HttpClient;
    eClient
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }
      ..maxConnectionsPerHost = maxConnectionsPerHost;
  }
}
