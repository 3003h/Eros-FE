import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fehviewer/common/update.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/models/profile.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:fehviewer/utils/https_proxy.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

  static PersistCookieJar cookieJar;

  static HttpProxy httpProxy = HttpProxy('localhost', '$kProxyPort');

  static String appSupportPath;
  static String appDocPath;
  static String tempPath;

  static bool isDBinappSupportPath = false;

  // 网络缓存对象
  // static NetCache netCache = NetCache();

  // init
  static Future<void> init() async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    // 判断是否debug模式
    inDebugMode = EHUtils().isInDebugMode;

    if (!inDebugMode) Logger.level = Level.info;

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

    logger.d('doc $appDocPath \napps $appSupportPath \ntemp $tempPath');

    // SP初始化
    await StorageUtil.init();

    await GStore.init();

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
  static void _profileInit() {
    _initProfile();
    _initHistory();
    // _initGalleryCaches();

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
      ..enableDoH = false
      ..dohCache = <DnsCache>[];

    profile.dnsConfig.dohCache = <DnsCache>[];

    if ((profile.dnsConfig.enableCustomHosts ?? false) ||
        (profile.dnsConfig.enableDoH ?? false)) {
      logger.v('${profile.dnsConfig.enableCustomHosts}');
      HttpOverrides.global = httpProxy;
    }

    history.history ??= <GalleryItem>[];

    profile.downloadConfig ??= DownloadConfig()..preloadImage = 5;
  }

  static void _initProfile() {
    final dynamic _profile = StorageUtil().getJSON(PROFILE);
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        print('get profile $e');
        rethrow;
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
    // logger.d('$_galleryCaches');
    if (_galleryCachesStr != null) {
      // logger.d(' $_galleryCachesStr');
      final List<dynamic> _galleryCaches = json.decode(_galleryCachesStr);
      for (final dynamic cache in _galleryCaches) {
        // logger.d('$cache');
        galleryCaches.add(GalleryCache.fromJson(cache));
      }
    }
  }

  static Future<bool> saveGalleryCaches() {
    galleryCaches.forEach((GalleryCache element) {
      // logger.d(' ${element.toJson()}');
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
