import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/bottomsheet/bottomsheet.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';
import 'package:get/get_navigation/src/routes/default_route.dart';

import 'eh_observer.dart';

class SecondNavigatorObserver extends EhNavigatorObserver {
  // 单例公开访问点
  factory SecondNavigatorObserver() => _sharedInstance();

  // 私有构造函数
  SecondNavigatorObserver._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static SecondNavigatorObserver _sharedInstance() {
    _instance ??= SecondNavigatorObserver._();
    return _instance!;
  }

  // 静态私有成员，没有初始化
  static SecondNavigatorObserver? _instance;
}
