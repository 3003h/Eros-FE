import 'dart:convert';

import 'package:FEhViewer/fehviewer/client/EhTagDatabase.dart';
import 'package:FEhViewer/models/profile.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/fehviewer/route/routes.dart';
import 'package:FEhViewer/fehviewer/route/Application.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 全局配置
class Global {
  // 是否第一次打开
  static bool isFirstOpen = false;
  static Profile profile = Profile();

  // init
  static Future init() async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    //statusBar设置为透明，去除半透明遮罩
    final SystemUiOverlayStyle _style =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(_style);

    // 工具初始
    await StorageUtil.init();

    try {
      EhTagDatabase.generateTagTranslat();
    } catch (e) {
      debugPrint('更新翻译异常 $e');
    }

    var _profile = StorageUtil().getJSON(PROFILE);
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        print(e);
      }
    }

//    try {
//      List<DisplayMode> modes = await FlutterDisplayMode.supported;
//      modes.forEach(print);
//    } on PlatformException catch (e) {
//      print(e);
//    }

    /// 测试
//    var database = await DataBaseUtil.getDataBase();
//    var count = await database.rawDelete('DELETE FROM tag_translat ');
//    debugPrint('$count');


    // 路由
    Router router = Router();
    EHRoutes.configureRoutes(router);
    Application.router = router;

    // 开启tag翻译
    StorageUtil().setBool(ENABLE_TAG_TRANSLAT, true);

    // 日语标题
    StorageUtil().setBool(ENABLE_JPN_TITLE, true);

    // 封面blur
    StorageUtil().setBool(ENABLE_IMG_BLUR, false);

    // 读取设备第一次打开
    isFirstOpen = !StorageUtil().getBool(STORAGE_DEVICE_ALREADY_OPEN_KEY);
    if (isFirstOpen) {
      StorageUtil().setBool(STORAGE_DEVICE_ALREADY_OPEN_KEY, true);
    }
  }


  // 持久化Profile信息
  static saveProfile() => StorageUtil().setJSON(PROFILE, profile);

}
