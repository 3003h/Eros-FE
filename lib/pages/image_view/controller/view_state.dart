import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:get/get.dart';

import '../common.dart';
import '../view/view_page.dart';
import 'view_contorller.dart';

class ViewExtState {
  /// 初始化操作
  ViewExtState() {
    // 设置加载类型
    if (Get.arguments is ViewRepository) {
      final ViewRepository vr = Get.arguments as ViewRepository;
      logger.d('vr.loadType ${vr.loadType}');
      loadFrom = vr.loadType;
      if (loadFrom == LoadFrom.download) {
        if (vr.files != null) {
          imagePathList = vr.files!;
          initGid = vr.gid;

          // 改为全局
          // _galleryCacheController
          //     .getGalleryCache(initGid ?? '', sync: false)
          //     .then((value) =>
          //         _columnMode = value?.columnMode ?? ViewColumnMode.single);
        }
      } else {
        galleryPageController = Get.find(tag: pageCtrlDepth);

        // 改为全局
        // _galleryCacheController
        //     .getGalleryCache(galleryPageController.galleryItem?.gid ?? '0',
        //         sync: false)
        //     .then((value) =>
        //         _columnMode = value?.columnMode ?? ViewColumnMode.single);
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
  LoadFrom loadFrom = LoadFrom.gallery;

  late final String? initGid;

  /// 当前的index
  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;
  set currentItemIndex(int val) {
    _currentItemIndex = val;

    // 防抖
    vDebounce(() => saveLastIndex(),
        duration: const Duration(milliseconds: 500));
    vDebounce(
      () => saveLastIndex(saveToStore: true),
      duration: const Duration(seconds: 5),
    );
  }

  void saveLastIndex({bool saveToStore = false}) {
    if (loadFrom == LoadFrom.gallery) {
      if (galleryPageController.galleryItem?.gid != null &&
          conditionItemIndex) {
        galleryPageController.lastIndex = currentItemIndex;
        _galleryCacheController.setIndex(
            galleryPageController.galleryItem?.gid ?? '0', currentItemIndex,
            saveToStore: saveToStore);
      }
    } else {
      if (initGid != null) {
        _galleryCacheController.setIndex(initGid ?? '', currentItemIndex,
            saveToStore: saveToStore);
      }
    }
  }

  /// 单页双页模式
  // ViewColumnMode _columnMode = ViewColumnMode.single;
  ViewColumnMode get columnMode => ehConfigService.viewColumnMode;
  set columnMode(ViewColumnMode val) {
    // _columnMode = val;
    // vDebounce(() {
    //   if (loadFrom == LoadFrom.gallery) {
    //     _galleryCacheController.setColumnMode(
    //         galleryPageController.galleryItem?.gid ?? '', val);
    //   }
    // });
    ehConfigService.viewColumnMode = val;
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
    if (loadFrom == LoadFrom.download) {
      return imagePathList.length;
    } else {
      return int.parse(galleryPageController.galleryItem?.filecount ?? '0');
    }
  }

  final Map<int, int> errCountMap = {};

  int retryCount = 3;

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
  set viewMode(ViewMode val) => _viewMode.value = val;

  bool fade = true;
  bool needRebuild = false;

  bool conditionItemIndex = true;
  int tempIndex = 0;

  // 显示底栏缩略图
  bool showThumbList = true;
  int centThumbIndex = 0;
  int minThumbIndex = 0;
  int maxThumbIndex = 0;

  // 同步滚动底栏缩略图
  bool syncThumbList = true;

  GalleryTaskDao? galleryTaskDao;
  ImageTaskDao? imageTaskDao;
  List<GalleryImageTask> imageTasks = <GalleryImageTask>[];
  String? dirPath;

  Map<int, Size> imageSizeMap = {};

  Timer? speedTimer;
  double tempPos = 0.0;
  double lastOffset = 0.0;
  final speedList = <double>[];

  int minImageIndex = 0;
  int maxImageIndex = 0;

  bool get isScrolling {
    final _first = speedList.firstOrNull ?? 0.00;
    return speedList.any((element) => element != _first);
  }
}
