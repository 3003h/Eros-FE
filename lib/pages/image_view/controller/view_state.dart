import 'dart:async';
import 'dart:ui';

import 'package:archive_async/archive_async.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:get/get.dart';

import '../common.dart';
import '../view/view_page.dart';
import 'view_controller.dart';

class ViewExtState {
  /// 初始化操作
  ViewExtState() {
    // 设置加载类型
    if (Get.arguments is ViewRepository) {
      final ViewRepository vr = Get.arguments as ViewRepository;
      logger.d('vr.loadType ${vr.loadType}, index: ${vr.index}');
      loadFrom = vr.loadType;

      switch (loadFrom) {
        case LoadFrom.download:
          if (vr.files != null) {
            imagePathList = vr.files!;
            gid = vr.gid;
          }
          break;
        case LoadFrom.gallery:
          galleryPageController =
              Get.find<GalleryPageController>(tag: pageCtrlTag);
          gid = galleryPageController?.gState.gid;
          break;
        case LoadFrom.archiver:
          logger.d('LoadFrom.archiver');
          gid = vr.gid;
          asyncArchiveFiles.addAll(vr.asyncArchives!);
      }

      currentItemIndex = vr.index;
    }

    ever(_currentItemIndex, (val) => saveLastIndex());
    debounce(_currentItemIndex, (callback) => saveLastIndex(saveToStore: true),
        time: 3.seconds);
  }

  GalleryPageController? galleryPageController;

  GalleryPageState? get pageState => galleryPageController?.gState;

  final EhConfigService ehConfigService = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();

  final CancelToken getMoreCancelToken = CancelToken();

  Map<int, GalleryImage>? get imageMap => pageState?.imageMap;
  RxList<GalleryImage>? get images => pageState?.images;

  LoadFrom loadFrom = LoadFrom.gallery;

  late final String? gid;

  /// 当前的index
  final _currentItemIndex = 0.obs;
  int get currentItemIndex => _currentItemIndex.value;
  set currentItemIndex(int val) {
    _currentItemIndex.value = val;
  }

  void saveLastIndex({bool saveToStore = false}) {
    if (loadFrom == LoadFrom.gallery) {
      if (pageState != null &&
          pageState?.galleryProvider?.gid != null &&
          conditionItemIndex) {
        pageState!.lastIndex = currentItemIndex;
        _galleryCacheController.setIndex(
            pageState!.galleryProvider?.gid ?? '0', currentItemIndex,
            saveToStore: saveToStore);
      }
    } else {
      if (gid != null) {
        _galleryCacheController.setIndex(gid ?? '', currentItemIndex,
            saveToStore: saveToStore);
      }
    }
  }

  /// 单页双页模式
  ViewColumnMode get columnMode => ehConfigService.viewColumnMode;

  set columnMode(ViewColumnMode val) {
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
    } else if (loadFrom == LoadFrom.gallery) {
      return int.parse(pageState?.galleryProvider?.filecount ?? '0');
    } else {
      return asyncArchiveFiles.length;
    }
  }

  final List<AsyncArchiveFile> asyncArchiveFiles = [];

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

  Map<String, AsyncArchive> asyncArchiveMap = {};
  Map<String, AsyncInputStream> asyncInputStreamMap = {};
}
