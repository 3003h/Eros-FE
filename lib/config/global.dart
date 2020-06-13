import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/route/Application.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

// 全局配置
class Global {
  // 是否第一次打开
  static bool isFirstOpen = false;

  // init
  static Future init() async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    // 工具初始
    await StorageUtil.init();

    // 路由
    Router router = Router();
    EHRoutes.configureRoutes(router);
    Application.router = router;

    // 读取设备第一次打开
    isFirstOpen = !StorageUtil().getBool(STORAGE_DEVICE_ALREADY_OPEN_KEY);
    if (isFirstOpen) {
      StorageUtil().setBool(STORAGE_DEVICE_ALREADY_OPEN_KEY, true);
    }
  }
}
