import 'dart:convert';
import 'dart:io';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/models/profile.dart';
import 'package:fehviewer/utils/https_proxy.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/network/gallery_request.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/values/storages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // pageController的tag
  static int pageCtrlDepth = 0;

  static Profile profile = Profile();

  static History history = History();
  static List<GalleryCache> galleryCaches = <GalleryCache>[];

  static CookieManager cookieManager;

  static HttpProxy httpProxy = HttpProxy('localhost', '$kProxyPort');

  static String appSupportPath;
  static String appDocPath;

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
    const SystemUiOverlayStyle _style =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(_style);

    appSupportPath = (await getApplicationSupportDirectory()).path;
    appDocPath = (await getApplicationDocumentsDirectory()).path;

    // SP初始化
    await StorageUtil.init();

    _profileInit();

    cookieManager = CookieManager(await Api.cookieJar);

    // 读取设备第一次打开
    isFirstOpen = !StorageUtil().getBool(STORAGE_DEVICE_ALREADY_OPEN_KEY);
    if (isFirstOpen) {
      _creatDirs();
      StorageUtil().setBool(STORAGE_DEVICE_ALREADY_OPEN_KEY, true);
    }

    isDBinappSupportPath = StorageUtil().getBool(IS_DB_IN_SUPPORT_DIR);
    if (!isFirstOpen && !isDBinappSupportPath) {
      // 不是第一次打开并且DB不位于 appSupport
      // 迁移DB数据
      logger.d('迁移DB数据');
      await _moveDB();
      StorageUtil().setBool(IS_DB_IN_SUPPORT_DIR, true);
    }
  }

  static void _creatDirs() {
    final Directory downloadDir = Directory(join(appDocPath, 'Download'));
    downloadDir.create();
  }

  /// 升级兼容处理 把数据库文件从doc目录移动到appSupport
  static Future<void> _moveDB() async {
    final Directory appDocDir = Directory(appDocPath);
    final Stream<FileSystemEntity> entityList =
        appDocDir.list(recursive: false, followLinks: false);
    await for (final FileSystemEntity entity in entityList) {
      //文件、目录和链接都继承自FileSystemEntity
      //FileSystemEntity.type静态函数返回值为FileSystemEntityType
      //FileSystemEntityType有三个常量：
      //Directory、FILE、LINK、NOT_FOUND
      //FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
      // print(entity.path);
      if (entity.path.endsWith('.db')) {
        final File _dbFile = File(entity.path);
        final String fileName =
            _dbFile.path.substring(_dbFile.path.lastIndexOf(separator) + 1);
        // print(join(appSupportPath, fileName));
        _dbFile.copySync(join(Global.appSupportPath, fileName));
        _dbFile.deleteSync();
      } else if (entity.path.endsWith('ie0_ps1')) {
        final Directory _ieDir = Directory(entity.path);
        final Directory _ieDirNew =
            Directory(_ieDir.path.replaceAll(appDocPath, appSupportPath));
        print(_ieDirNew.path);
        final Stream<FileSystemEntity> _ieList =
            _ieDir.list(recursive: false, followLinks: false);
        await for (final FileSystemEntity _ieEntity in _ieList) {
          // print(_ieEntity.path);
          final File _cookieFile = File(_ieEntity.path);
          final String _cookieFileName = _cookieFile.path
              .substring(_cookieFile.path.lastIndexOf(separator) + 1);
          // print('to  ' + join(appSupportPath, _cookieFileName));
          _cookieFile.copySync(join(Global.appSupportPath, _cookieFileName));
          _cookieFile.deleteSync();
        }
        _ieDir.deleteSync();
      }
    }
    _creatDirs();
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
