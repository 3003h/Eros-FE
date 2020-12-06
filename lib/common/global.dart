import 'dart:convert';
import 'dart:io';

import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/profile.dart';
import 'package:FEhViewer/route/application.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/cache.dart';
import 'package:FEhViewer/utils/https_proxy.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

const int kProxyPort = 4041;

// 全局配置
// ignore: avoid_classes_with_only_static_members
class Global {
  // 是否第一次打开
  static bool isFirstOpen = false;
  static bool inDebugMode = false;
  static bool isFirstReOpenEhSetting = true;
  static Profile profile = Profile();
  static History history = History();
  static List<GalleryCache> galleryCaches = <GalleryCache>[];

  static CookieManager cookieManager;

  static HttpProxy httpProxy = HttpProxy('localhost', '$kProxyPort');

  // 网络缓存对象
  static NetCache netCache = NetCache();

  static final Logger logger = Logger(
    output: ExampleLogOutput(),
    printer: PrettyPrinter(
      lineLength: 100,
      colors: false,
    ),
  );

  static final Logger loggerNoStack = Logger(
    output: ExampleLogOutput(),
    printer: PrettyPrinter(
      lineLength: 100,
      methodCount: 0,
      colors: false,
    ),
  );

  // init
  static Future<void> init() async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    // 代理初始化
    await CustomHttpsProxy.instance.init();

    //statusBar设置为透明，去除半透明遮罩
    const SystemUiOverlayStyle _style =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(_style);

    // SP初始化
    await StorageUtil.init();

    _profileInit();

    cookieManager = CookieManager(await Api.cookieJar);

    // 路由
    final FluroRouter router = FluroRouter();
    EHRoutes.configureRoutes(router);
    Application.router = router;

    // 判断是否debug模式
    inDebugMode = EHUtils().isInDebugMode;

    // 读取设备第一次打开
    isFirstOpen = !StorageUtil().getBool(STORAGE_DEVICE_ALREADY_OPEN_KEY);
    if (isFirstOpen) {
      StorageUtil().setBool(STORAGE_DEVICE_ALREADY_OPEN_KEY, true);
    }
  }

  /// profile初始化
  static void _profileInit() {
    _initProfile();
    _initHistory();
    _initGalleryCaches();

    if (profile.ehConfig == null) {
      profile.ehConfig = EhConfig()
        ..safeMode = Platform.isIOS
        ..maxHistory = 100
        ..siteEx = false
        ..tagTranslat = false
        ..jpnTitle = false
        ..favLongTap = false
        ..favPicker = false
        ..galleryImgBlur = false;
      saveProfile();
    }

    if (profile.advanceSearch == null) {
      profile.advanceSearch = AdvanceSearch()
        ..searchGalleryName = true
        ..searchGalleryTags = true;
      saveProfile();
    }

    profile.cache ??= CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 200;

    profile.searchText ??= <String>[];

    profile.localFav ??= LocalFav()..gallerys = <GalleryItem>[];

    profile.dnsConfig ??= DnsConfig()
      ..hosts = <DnsCache>[]
      ..doh = false
      ..cache = <DnsCache>[];

    if (profile.dnsConfig.customHosts ?? false) {
      logger.v('${profile.dnsConfig.customHosts}');
      HttpOverrides.global = httpProxy;
    }

    history.history ??= <GalleryItem>[];
  }

  static void _initProfile() {
    final dynamic _profile = StorageUtil().getJSON(PROFILE);
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        print('get profile $e');
      }
    }
  }

  // 持久化Profile信息
  static Future<bool> saveProfile() {
    // logger.v(profile.toJson());
    return StorageUtil().setJSON(PROFILE, profile);
  }

  static void _initGalleryCaches() {
    final dynamic _galleryCachesStr = StorageUtil().getJSON(GALLERY_CACHE);
    // Global.logger.d('$_galleryCaches');
    if (_galleryCachesStr != null) {
      // Global.logger.d(' $_galleryCachesStr');
      final List<dynamic> _galleryCaches = json.decode(_galleryCachesStr);
      for (final dynamic cache in _galleryCaches) {
        // Global.logger.d('$cache');
        galleryCaches.add(GalleryCache.fromJson(cache));
      }
    }
  }

  static Future<bool> saveGalleryCaches() {
    galleryCaches.forEach((GalleryCache element) {
      // Global.logger.d(' ${element.toJson()}');
    });
    return StorageUtil().setJSON(GALLERY_CACHE, galleryCaches);
  }

  static void _initHistory() {
    final dynamic _history = StorageUtil().getJSON(HISTORY);
    if (_history != null) {
      try {
        history = History.fromJson(jsonDecode(_history));
      } catch (e) {
        print('getHistoryFromSP $e');
      }
    }
  }

  static Future<bool> saveHistory() async {
    return StorageUtil().setJSON(HISTORY, history);
  }
}

class ExampleLogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    LogConsole.add(event);
  }
}
