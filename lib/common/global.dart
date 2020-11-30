import 'dart:convert';
import 'dart:io';

import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/profile.dart';
import 'package:FEhViewer/route/application.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/https_proxy.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/storages.dart';
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

  static HttpProxy httpProxy = HttpProxy('localhost', '$kProxyPort');

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

    await CustomHttpsProxy.instance.init();

    //statusBar设置为透明，去除半透明遮罩
    const SystemUiOverlayStyle _style =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(_style);

    // 工具初始
    await StorageUtil.init();

    // ignore: always_specify_types
    final _profile = StorageUtil().getJSON(PROFILE);
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        print('get profile $e');
      }
    }

    getHistoryFromSP();

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

  // 持久化Profile信息
  static Future<bool> saveProfile() {
    // logger.v(profile.toJson());
    return StorageUtil().setJSON(PROFILE, profile);
  }

  static Future<bool> saveHistory() async {
    // logger.v(history.toJson());
    // logger.v('${history.history.length}');
    return StorageUtil().setJSON(HISTORY, history);
  }

  static Future<void> getHistoryFromSP() async {
    // ignore: always_specify_types
    final _history = StorageUtil().getJSON(HISTORY);
    if (_history != null) {
      try {
        history = History.fromJson(jsonDecode(_history));
      } catch (e) {
        print('getHistoryFromSP $e');
      }
    }
  }
}

class ExampleLogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    LogConsole.add(event);
  }
}
