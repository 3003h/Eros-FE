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
  static Map hosts = {};

  static HttpProxy httpProxy = HttpProxy._('localhost', '$kProxyPort');

  static final Logger logger = Logger(
    printer: PrettyPrinter(
      lineLength: 100,
      colors: false,
    ),
  );

  static final Logger loggerNoStack = Logger(
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

    hosts['exhentai.org'] = 'e9c94a2e71d54b2f96019697060e89d6.pacloudflare.com';
    final CustomHttpsProxy proxy = CustomHttpsProxy.instance;
    await proxy.init();

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
        print(e);
      }
    }

    if (profile.dnsConfig.doh ??
        false || profile.dnsConfig.customHosts ??
        false) {
      HttpOverrides.global = Global.httpProxy;
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
        print(e);
      }
    }
  }
}

class HttpProxy extends HttpOverrides {
  HttpProxy._(this.host, this.port);
  String host;
  String port;

  @override
  HttpClient createHttpClient(SecurityContext context) {
    final HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String> environment) {
    if (host == null) {
      return super.findProxyFromEnvironment(url, environment);
    }

    environment ??= {};

    if (port != null) {
      environment['http_proxy'] = '$host:$port';
      environment['https_proxy'] = '$host:$port';
    } else {
      environment['http_proxy'] = '$host:8888';
      environment['https_proxy'] = '$host:8888';
    }

    return super.findProxyFromEnvironment(url, environment);
  }
}
