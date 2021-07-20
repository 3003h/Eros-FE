import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'view_ext_state.dart';

/// 支持在线以及本地（已下载）阅读的组件
class ViewExtController extends GetxController {
  /// 状态
  final ViewExtState vState = ViewExtState();

  late PageController pageController;

  @override
  void onInit() {
    super.onInit();

    // 横屏模式pageview控制器初始化
    pageController = PageController(
        initialPage: vState.currentItemIndex, viewportFraction: 1.0);
  }

  // 页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    logger.d('PageChanged $pageIndex');
  }
}
