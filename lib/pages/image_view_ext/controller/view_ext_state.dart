import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:get/get.dart';

import '../common.dart';
import '../view/view_ext_page.dart';
import 'view_ext_contorller.dart';

class ViewExtState {
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
        _columnMode = _galleryCacheController
                .getGalleryCache(galleryPageController.galleryItem.gid ?? '')
                ?.columnMode ??
            ViewColumnMode.single;
      }

      currentItemIndex = vr.index;
    }
  }

  late final GalleryPageController galleryPageController;

  final EhConfigService ehConfigService = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();

  final CancelToken getMoreCancelToken = CancelToken();

  Map<int, GalleryImage> get imageMap => galleryPageController.imageMap;

  ///
  LoadType loadType = LoadType.network;

  /// 当前的index
  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;
  set currentItemIndex(int val) {
    _currentItemIndex = val;

    // 防抖
    vDebounce(() => saveLastIndex(), duration: Duration(milliseconds: 500));
    vDebounce(
      () => saveLastIndex(saveToStore: true),
      duration: const Duration(seconds: 5),
    );
  }

  void saveLastIndex({bool saveToStore = false}) {
    if (loadType == LoadType.network) {
      if (galleryPageController.galleryItem.gid != null && conditionItemIndex) {
        galleryPageController.lastIndex = currentItemIndex;
        _galleryCacheController.setIndex(
            galleryPageController.galleryItem.gid ?? '', currentItemIndex,
            saveToStore: saveToStore);
      }
    }
  }

  /// 单页双页模式
  ViewColumnMode _columnMode = ViewColumnMode.single;
  ViewColumnMode get columnMode => _columnMode;
  set columnMode(ViewColumnMode val) {
    _columnMode = val;
    vDebounce(() {
      if (loadType == LoadType.network) {
        _galleryCacheController.setColumnMode(
            galleryPageController.galleryItem.gid ?? '', val);
      }
    });
  }

  /// pageview下实际的index
  int get pageIndex {
    switch (columnMode) {
      case ViewColumnMode.single:
        return currentItemIndex;
      case ViewColumnMode.oddLeft:
        return currentItemIndex ~/ 2;
      case ViewColumnMode.evenLeft:
        return (currentItemIndex + 1) ~/ 2;
      default:
        return currentItemIndex;
    }
  }

  /// pageview下实际能翻页的总数
  int get pageCount {
    final int imageCount = filecount;
    switch (columnMode) {
      case ViewColumnMode.single:
        return imageCount;
      case ViewColumnMode.oddLeft:
        return (imageCount / 2).round();
      case ViewColumnMode.evenLeft:
        return (imageCount / 2).round() + ((imageCount + 1) % 2);
      default:
        return imageCount;
    }
  }

  double sliderValue = 0.0;

  /// imagePathList
  List<String> imagePathList = <String>[];

  int get filecount {
    if (loadType == LoadType.file) {
      return imagePathList.length;
    } else {
      return int.parse(galleryPageController.galleryItem.filecount ?? '0');
    }
  }

  final Map<int, int> errCountMap = {};

  int retryCount = 7;

  List<double> doubleTapScales = <double>[1.0, 2.0, 3.0];

  /// 显示页面间隔
  RxBool get _showPageInterval => ehConfigService.showPageInterval;
  bool get showPageInterval => _showPageInterval.value;
  set showPageInterval(bool val) => _showPageInterval.value = val;

  /// 显示Bar
  bool showBar = false;

  /// 底栏高度
  double bottomBarHeight = -1;

  /// 底栏偏移
  double get bottomBarOffset {
    if (showBar) {
      return 0;
    } else {
      return -bottomBarHeight;
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

  bool autoRead = false;
  Map<int, bool> loadCompleMap = <int, bool>{};
  int? lastAutoNextSer;
  int serStart = 0;

  /// 阅读模式
  Rx<ViewMode> get _viewMode => ehConfigService.viewMode;
  ViewMode get viewMode => _viewMode.value;
  set viewMode(val) => _viewMode.value = val;

  bool fade = true;
  bool needRebuild = false;

  bool conditionItemIndex = true;
  int tempIndex = 0;

  bool showThumbList = false;
  int mindThumbIndex = 0;
  bool syncThumbList = true;
}
