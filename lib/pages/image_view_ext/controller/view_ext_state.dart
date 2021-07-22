import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import '../view/view_ext_page.dart';
import 'view_ext_contorller.dart';

enum LoadType {
  network,
  file,
}

class ViewExtState {
  double sliderValue = 0.0;

  /// 初始化操作
  ViewExtState() {
    // 设置加载类型
    if (Get.arguments is ViewRepository) {
      final ViewRepository vr = Get.arguments;
      loadType = vr.loadType;
      if (loadType == LoadType.file) {
        if (vr.files != null) {
          imagePathList = vr.files!;
        }
      } else {
        galleryPageController = Get.find(tag: pageCtrlDepth);
      }

      currentItemIndex = vr.index;
    }
  }

  late final GalleryPageController galleryPageController;

  final EhConfigService ehConfigService = Get.find();

  final CancelToken getMoreCancelToken = CancelToken();

  ///
  LoadType loadType = LoadType.network;

  /// 当前的index
  int currentItemIndex = 0;

  /// imagePathList
  List<String> imagePathList = <String>[];

  int get filecount {
    if (loadType == LoadType.file) {
      return imagePathList.length;
    } else {
      return int.parse(galleryPageController.galleryItem.filecount ?? '0');
    }
  }

  ///
  int get pageCount {
    return filecount;
  }

  final Map<int, int> errCountMap = {};

  int retryCount = 7;

  List<double> doubleTapScales = <double>[1.0, 2.0, 3.0];

  /// 显示Bar
  bool showBar = false;

  /// 底栏偏移
  double get bottomBarOffset {
    final _paddingBottom = Get.context!.mediaQueryPadding.bottom;

    if (showBar) {
      return 0;
    } else {
      return -kBottomBarHeight * 2 - _paddingBottom;
    }
  }

  /// 顶栏偏移
  double get topBarOffset {
    final _paddingTop = Get.context!.mediaQueryPadding.top;

    final double _offsetTopHide = kTopBarHeight + _paddingTop;
    if (showBar) {
      return 0;
    } else {
      return -_offsetTopHide - 10;
    }
  }
}
