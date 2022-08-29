import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive_async/archive_async.dart';
import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/store/archive_async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:synchronized/synchronized.dart';
import 'package:throttling/throttling.dart';
import 'package:wakelock/wakelock.dart';

import 'view_state.dart';

// 底栏控制栏按钮高度
const double kBottomBarButtonHeight = 54.0;

// 底栏控制栏高度
const double kBottomBarHeight = 64.0;

// 底栏滑动栏高度
const double kSliderBarHeight = 64.0;

// 顶栏高度
const double kTopBarHeight = 44.0;

// 顶栏按钮高度
const double kTopBarButtonHeight = 44.0;

// 缩略图栏高度
const double kThumbListViewHeight = 140.0;
const double kThumbImageWidth = kThumbListViewHeight / 2 - 10;

const String idViewTopBar = 'ViewTopBar';
const String idViewBottomBar = 'ViewBottomBar';
const String idViewBar = 'ViewBar';
const String idViewPageSlider = 'ViewPageSlider';
const String idSlidePage = 'ViewImageSlidePage';
const String idImagePageView = 'ImagePageView';
const String idImageListView = 'ImageListView';
const String idViewColumnModeIcon = 'ViewColumnModeIcon';
const String idThumbnailListView = 'ThumbnailListView';
const String idShowThumbListIcon = 'ShowThumbListIcon';
const String idAutoReadIcon = 'AutoReadIcon';
const String idIconBar = 'IconBar';
const String idProcess = 'Process';

const int _speedMaxCount = 50;
const int _speedInv = 10;

enum PageViewType {
  photoView,
  preloadPageview,
  extendedImageGesturePageView,
}

/// 支持在线以及本地（已下载）阅读的组件
class ViewExtController extends GetxController {
  ViewExtController();

  /// 状态
  final ViewExtState vState = ViewExtState();

  // 使用 PhotoView
  final pageViewType = PageViewType.preloadPageview;

  final _absorbing = false.obs;
  bool get absorbing => _absorbing.value;
  set absorbing(bool val) => _absorbing.value = val;

  late PageController pageController;
  late ExtendedPageController extendedPageController;

  late PreloadPageController preloadPageController;

  GalleryPageController? get _galleryPageController =>
      vState.galleryPageController;

  GalleryPageState? get _galleryPageStat => vState.pageState;

  EhConfigService get _ehConfigService => vState.ehConfigService;

  final ArchiverDownloadController archiverDownloadController = Get.find();

  Map<String, DownloadArchiverTaskInfo> get archiverTaskMap =>
      archiverDownloadController.archiverTaskMap;

  Map<int, Future<GalleryImage?>> imageFutureMap = {};

  Map<int, Stream<GalleryImage?>> imageStreamMap = {};

  Map<int, Future<File?>> imageArchiveFutureMap = {};

  final imageArchiveLock = Lock();

  final imageLock = Lock();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController thumbScrollController = ItemScrollController();
  final ItemPositionsListener thumbPositionsListener =
      ItemPositionsListener.create();

  final AutoScrollController autoScrollController = AutoScrollController();
  final photoViewScaleStateController = PhotoViewScaleStateController();

  final FlutterListViewController flutterListViewController =
      FlutterListViewController();

  final PhotoViewController photoViewController = PhotoViewController();

  final GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();

  Timer? autoNextTimer;

  @override
  void onInit() {
    super.onInit();

    // 横屏模式pageview控制器初始化
    pageController = PageController(
      initialPage: vState.pageIndex,
      viewportFraction: vState.showPageInterval ? 1.1 : 1.0,
      // viewportFraction: 0.999999,
    );

    preloadPageController = PreloadPageController(
      initialPage: vState.pageIndex,
      // viewportFraction: vState.showPageInterval
      //     ? (Get.context!.width + 10) / Get.context!.width
      //     : 1.0,
      // viewportFraction: vState.showPageInterval ? 1.1 : 1.0,
    );

    extendedPageController = ExtendedPageController(
      initialPage: vState.pageIndex,
      shouldIgnorePointerWhenScrolling: true,
      pageSpacing: vState.showPageInterval ? 20.0 : 0.0,
    );

    // 竖屏模式初始页码
    if (vState.viewMode == ViewMode.topToBottom) {
      // logger.v('竖屏模式初始页码: ${vState.itemIndex}');
      Future.delayed(const Duration(milliseconds: 50)).then((value) =>
          itemScrollController.jumpTo(index: vState.currentItemIndex));

      vState.speedTimer = Timer.periodic(
        const Duration(milliseconds: _speedInv),
        (timer) {
          // loggerSimple.d('${vState.tempPos}');
          final offset = vState.tempPos;
          vState.speedList.add(offset);
          if (vState.speedList.length > _speedMaxCount) {
            vState.speedList.removeAt(0);
          }
        },
      );
    }

    // list视图滚动监听
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      vState.tempPos = positions.first.itemLeadingEdge;
      handItemPositionsChange(positions);
    });

    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      if (thumbScrollController.isAttached) {
        thumbScrollController.jumpTo(index: vState.currentItemIndex);
      }
    });

    // 缩略图滚动组件监听
    thumbPositionsListener.itemPositions.addListener(() {
      final positions = thumbPositionsListener.itemPositions.value;
      handThumbPositionsChange(positions);
    });

    photoViewScaleStateController.outputScaleStateStream.listen((state) {
      final prevScaleState = photoViewScaleStateController.prevScaleState;
      logger.d('prevScaleState $prevScaleState , cur state $state');
    });
  }

  @override
  void onReady() {
    super.onReady();

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    if (vState.loadFrom == LoadFrom.gallery) {
      // 预载
      logger.v('初始预载');

      GalleryPara.instance
          .ehPrecacheImages(
        imageMap: vState.imageMap,
        itemSer: vState.currentItemIndex,
        max: _ehConfigService.preloadImage.value,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController?.uptImageBySer(
              ser: event.ser, imageCallback: (image) => event);
        }
      });
    }

    logger.v('旋转设置');
    final ReadOrientation? _orientation = _ehConfigService.orientation.value;
    // logger.d(' $_orientation');
    if (_orientation != ReadOrientation.system &&
        _orientation != ReadOrientation.auto) {
      OrientationPlugin.setPreferredOrientations(
          [orientationMap[_orientation] ?? DeviceOrientation.portraitUp]);
    }

    vState.sliderValue = vState.currentItemIndex / 1.0;

    // setFullscreen();
    400.milliseconds.delay(() => setFullscreen());
  }

  @override
  void onClose() {
    cancelAutoRead();
    autoNextTimer?.cancel();
    autoNextTimer = null;

    vState.speedTimer?.cancel();
    Get.find<GalleryCacheController>().saveAll();
    vState.saveLastIndex(saveToStore: true);
    flutterListViewController.dispose();
    pageController.dispose();
    extendedPageController.dispose();
    vState.getMoreCancelToken.cancel();

    // unsetFullscreen();
    400.milliseconds.delay(() => unsetFullscreen());

    // 恢复系统旋转设置
    logger.v('恢复系统旋转设置');
    OrientationPlugin.setPreferredOrientations(DeviceOrientation.values);

    vState.asyncInputStreamMap.values.map((e) => e.close());

    super.onClose();
  }

  Future<void> initArchiveFuture(int ser, {AsyncArchiveFile? asyncFile}) async {
    final file = asyncFile ?? vState.asyncArchiveFiles[ser - 1];
    logger.v('load ${file.name}');
    imageArchiveFutureMap[ser] = getArchiveFile(vState.gid, file);
  }

  Future<void> initFuture(int ser) async {
    imageFutureMap[ser] = fetchImage(ser);
  }

  Future<File> getArchiveFile(String? gid, AsyncArchiveFile file) async {
    // 同步锁 保证同时只有一个读取操作
    return await imageArchiveLock.synchronized(() => _getFile(gid, file));
  }

  Future<File> _getFile(String? gid, AsyncArchiveFile file) async {
    final outFile = File(path.join(Global.tempPath, 'archive_$gid', file.name));
    if (outFile.existsSync()) {
      return outFile;
    }
    final fileData = await file.getContent();
    await outFile.create(recursive: true);
    await outFile.writeAsBytes(fileData as Uint8List);
    return outFile;
  }

  void resetPageController() {
    pageController.dispose();
    extendedPageController.dispose();

    pageController = PageController(
      initialPage: pageController.positions.isNotEmpty
          ? pageController.page?.round() ?? vState.currentItemIndex
          : vState.currentItemIndex,
      viewportFraction: vState.showPageInterval ? 1.1 : 1.0,
    );

    extendedPageController = ExtendedPageController(
      initialPage: pageController.positions.isNotEmpty
          ? pageController.page?.round() ?? vState.currentItemIndex
          : vState.currentItemIndex,
      shouldIgnorePointerWhenScrolling: true,
      pageSpacing: vState.showPageInterval ? 20.0 : 0.0,
    );
  }

  // 横向页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    // 根据 columnMode 的不同设置不同的 currentItemIndex 值
    switch (vState.columnMode) {
      case ViewColumnMode.single:
        vState.currentItemIndex = pageIndex;
        break;
      case ViewColumnMode.oddLeft:
        vState.currentItemIndex = pageIndex * 2;
        break;
      case ViewColumnMode.evenLeft:
        final int index = pageIndex * 2 - 1;
        vState.currentItemIndex = index > 0 ? index : 0;
        break;
    }

    if (vState.loadFrom == LoadFrom.gallery) {
      // 预载图片
      // logger.v('页码切换时的回调 预载图片');
      GalleryPara.instance
          .ehPrecacheImages(
        imageMap: _galleryPageStat?.imageMap,
        itemSer: vState.currentItemIndex,
        max: _ehConfigService.preloadImage.value,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController?.uptImageBySer(
              ser: event.ser, imageCallback: (val) => event);
        }
      });
    }

    if (vState.currentItemIndex >= vState.filecount - 1) {
      vState.sliderValue = (vState.filecount - 1).toDouble();
    } else if (vState.currentItemIndex < 0) {
      vState.sliderValue = 1.0;
    } else {
      vState.sliderValue = vState.currentItemIndex.toDouble();
    }
    update([idViewTopBar, idViewPageSlider]);
    if (vState.syncThumbList) {
      thumbScrollTo();
    }
  }

  /// 切换单页双页模式
  Future<void> switchColumnMode() async {
    vibrateUtil.light();
    logger.v('切换单页双页模式');
    late final int _toIndex;
    switch (vState.columnMode) {
      case ViewColumnMode.single:
        logger.d('单页 => 双页1. itemIndex:${vState.currentItemIndex},');
        vState.columnMode = ViewColumnMode.oddLeft;
        _toIndex = vState.pageIndex;
        break;
      case ViewColumnMode.oddLeft:
        logger.d('双页1 => 双页2, itemIndex:${vState.currentItemIndex}');
        vState.columnMode = ViewColumnMode.evenLeft;
        _toIndex = vState.pageIndex;
        break;
      case ViewColumnMode.evenLeft:
        logger.d('双页2 => 单页, itemIndex:${vState.currentItemIndex}');
        vState.columnMode = ViewColumnMode.single;
        _toIndex = vState.pageIndex;
        break;
    }

    logger.d('_toIndex $_toIndex  ');
    update([idViewColumnModeIcon, idSlidePage]);
    await Future.delayed(const Duration(milliseconds: 50));

    // resetPageController();

    // pageController.jumpToPage(_toIndex);
    // extendedPageController.jumpToPage(_toIndex);

    // pageControllerCallBack(() => pageController.jumpToPage(_toIndex),
    //     () => extendedPageController.jumpToPage(_toIndex));
    changePage(_toIndex, animate: false);
  }

  Future<void> switchShowThumbList() async {
    if (vState.showThumbList) {
      vState.showThumbList = false;
    } else {
      vState.showThumbList = true;
    }

    update([idShowThumbListIcon, idViewBottomBar, idThumbnailListView]);
  }

  final Map<int, Future<void>?> _mapFetchGalleryPriviewPage = {};

  /// 拉取图片信息
  Future<GalleryImage?> fetchThumb(
    int itemSer, {
    bool refresh = false,
    bool changeSource = false,
  }) async {
    final GalleryImage? tImage = _galleryPageStat?.imageMap[itemSer];
    if (tImage == null) {
      logger.d('fetchThumb ser:$itemSer 所在页尚未获取， 开始获取');
      _mapFetchGalleryPriviewPage.putIfAbsent(
          itemSer, () => _galleryPageController?.loadImagesForSer(itemSer));

      // 直接获取需要的ser所在页
      await _mapFetchGalleryPriviewPage[itemSer];
    }

    final GalleryImage? image = _galleryPageStat?.imageMap[itemSer];

    return image;
  }

  Future<GalleryImage?> _getImageFromImageTasks(
    int itemSer,
    String? dir, {
    bool reLoadDB = false,
  }) async {
    if (dir == null) {
      return null;
    }

    if (reLoadDB) {
      vState.imageTasks = (await vState.imageTaskDao?.findAllTaskByGid(
              int.tryParse(_galleryPageStat?.gid ?? '') ?? 0)) ??
          [];
    }

    final imageTask = vState.imageTasks
        .firstWhereOrNull((imageTask) => imageTask.ser == itemSer);

    if (imageTask != null &&
        imageTask.filePath != null &&
        imageTask.filePath!.isNotEmpty &&
        imageTask.status == TaskStatus.complete.value) {
      return GalleryImage(
        ser: itemSer,
        completeDownload: true,
        filePath: path.join(dir, imageTask.filePath!),
      );
    }
    return null;
  }

  Future<String?> _getTaskDirPath(int gid) async {
    final gtask = await vState.galleryTaskDao!.findGalleryTaskByGid(gid);
    return gtask?.realDirPath;
  }

  /// 拉取图片信息
  Future<GalleryImage?> fetchImage(
    int itemSer, {
    bool changeSource = false,
  }) async {
    // 首先检查下载记录中是否有记录
    vState.imageTaskDao ??= Get.find<DownloadController>().imageTaskDao;
    vState.galleryTaskDao ??= Get.find<DownloadController>().galleryTaskDao;
    vState.dirPath ??=
        await _getTaskDirPath(int.tryParse(_galleryPageStat?.gid ?? '') ?? 0);

    late GalleryImage? image;

    // 检查是否已下载
    image = await _getImageFromImageTasks(itemSer, vState.dirPath);
    image ??=
        await _getImageFromImageTasks(itemSer, vState.dirPath, reLoadDB: true);

    // 检查是否已下载archive
    image ??= await getFromArchiverTask(itemSer);

    // 请求页面 解析为 [GalleryImage]
    if (image == null) {
      final tImage = _galleryPageStat?.imageMap[itemSer];
      if (tImage == null) {
        logger.d('ser:$itemSer 所在页尚未获取， 开始获取');

        // 直接获取所在页数据
        await _galleryPageController?.loadImagesForSer(itemSer);
      }

      GalleryPara.instance
          .ehPrecacheImages(
        imageMap: _galleryPageStat?.imageMap,
        itemSer: itemSer,
        max: _ehConfigService.preloadImage.value,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController?.uptImageBySer(
              ser: event.ser, imageCallback: (val) => val = event);
        }
      });

      image = await _galleryPageController?.fetchAndParserImageInfo(
        itemSer,
        cancelToken: vState.getMoreCancelToken,
        changeSource: changeSource,
      );
    }

    return image;
  }

  Future<GalleryImage?> getFromArchiverTask(int itemSer) async {
    final gid = vState.gid;
    // 读取缓存
    AsyncArchive? asyncArchive = vState.asyncArchiveMap[gid];

    if (asyncArchive == null && gid != null) {
      // archiver任务
      final task = archiverTaskMap.values
          .sorted((t1, t2) => (t1.type ?? '').compareTo(t2.type ?? ''))
          .where((element) =>
              element.gid == _galleryPageStat?.gid &&
              element.status == DownloadTaskStatus.complete.value)
          .toList()
          .firstOrNull;

      if (task == null) {
        return null;
      }

      final filePath = path.join(task.savedDir ?? '', task.fileName);

      // 异步读取zip
      final tuple = await readAsyncArchive(filePath.realArchiverPath);
      asyncArchive = tuple.item1;
      final asyncInputStream = tuple.item2;
      vState.asyncArchiveMap[gid] = asyncArchive;
      vState.asyncInputStreamMap[gid] = asyncInputStream;
    }

    if (asyncArchive == null) {
      return null;
    }

    final file =
        await getArchiveFile(vState.gid, asyncArchive.files[itemSer - 1]);

    return GalleryImage(
        ser: itemSer, gid: _galleryPageStat?.gid, tempPath: file.path);
  }

  /// 重载图片数据，重构部件
  Future<void> reloadImage(int itemSer, {bool changeSource = true}) async {
    final GalleryImage? _currentImage = _galleryPageStat?.imageMap[itemSer];
    // 清除CachedNetworkImage的缓存
    try {
      // CachedNetworkImage 清除指定缓存
      // await CachedNetworkImage.evictFromCache(_currentImage?.imageUrl ?? '');
      // extended_image 清除指定缓存
      await clearDiskCachedImage(_currentImage?.imageUrl ?? '');
      clearMemoryImageCache();
    } catch (_) {}

    if (_currentImage == null) {
      return;
    }
    _galleryPageController?.uptImageBySer(
      ser: itemSer,
      imageCallback: (image) => image.copyWith(
        imageUrl: '',
        changeSource: changeSource,
        completeCache: false,
      ),
    );

    // 换源重载
    imageFutureMap[itemSer] = fetchImage(
      itemSer,
      changeSource: changeSource,
    );

    // update();
    update(['$idImageListView$itemSer']);
  }

  void setScale100(ImageInfo imageInfo, Size size) {
    final sizeImage = Size(
        imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());

    final double _scalesS100 = scale100(size: size, imageSize: sizeImage);

    if (vState.doubleTapScales.length < 3) {
      vState.doubleTapScales.add(_scalesS100);
    } else {
      vState.doubleTapScales[2] = _scalesS100;
    }
  }

  // 点击中间
  Future<void> handOnTapCent() async {
    if (vState.viewMode == ViewMode.topToBottom && vState.isScrolling) {
      return;
    }

    // android会有抖动
    if (GetPlatform.isIOS) {
      if (!vState.showBar) {
        unsetFullscreen();
        vState.showBar = !vState.showBar;
      } else {
        // hide
        vState.showBar = !vState.showBar;
        400.milliseconds.delay(() => setFullscreen());
      }
    } else {
      vState.showBar = !vState.showBar;
    }

    update([idViewBar]);
  }

  void setFullscreen() {
    if (_ehConfigService.viewFullscreen) {
      FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    }
  }

  Future<void> unsetFullscreen() async {
    await FullScreen.exitFullScreen();
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   systemNavigationBarColor: Colors.transparent,
    //   systemNavigationBarDividerColor: Colors.transparent,
    //   statusBarColor: Colors.transparent,
    // ));
  }

  void changePage(
    int page, {
    Duration duration = const Duration(milliseconds: 200),
    bool? animate,
  }) {
    final enableAnimate = animate ?? _ehConfigService.tapToTurnPageAnimations;

    if (enableAnimate) {
      switch (pageViewType) {
        case PageViewType.photoView:
          pageController.animateToPage(
            page,
            duration: duration,
            curve: Curves.ease,
          );
          break;
        case PageViewType.preloadPageview:
          preloadPageController.animateToPage(
            page,
            duration: duration,
            curve: Curves.ease,
          );
          break;
        default:
          extendedPageController.animateToPage(
            page,
            duration: duration,
            curve: Curves.ease,
          );
      }
    } else {
      switch (pageViewType) {
        case PageViewType.photoView:
          pageController.jumpToPage(page);
          break;
        case PageViewType.preloadPageview:
          preloadPageController.jumpToPage(page);
          break;
        default:
          extendedPageController.jumpToPage(page);
      }
    }
  }

  Future<void> tapLeft() async {
    logger.v('${vState.viewMode} tap left');
    final enableAnimate = _ehConfigService.tapToTurnPageAnimations;

    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight && vState.pageIndex > 0) {
      final toPage = vState.pageIndex - 1;
      changePage(toPage);
    } else if (vState.viewMode == ViewMode.rightToLeft &&
        vState.pageIndex < vState.filecount) {
      final toPage = vState.pageIndex + 1;
      changePage(toPage);
    } else if (vState.viewMode == ViewMode.topToBottom &&
        itemScrollController.isAttached &&
        !vState.isScrolling &&
        vState.pageIndex > 0) {
      logger.v('${vState.minImageIndex}');
      itemScrollController.scrollTo(
        index: vState.minImageIndex - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }

  Future<void> tapRight() async {
    logger.v('${vState.viewMode} tap right');
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight &&
        vState.pageIndex < vState.filecount) {
      final toPage = vState.pageIndex + 1;
      changePage(toPage);
    } else if (vState.viewMode == ViewMode.rightToLeft &&
        vState.pageIndex > 0) {
      final toPage = vState.pageIndex - 1;
      changePage(toPage);
    } else if (vState.viewMode == ViewMode.topToBottom &&
        itemScrollController.isAttached &&
        !vState.isScrolling &&
        vState.pageIndex < vState.filecount) {
      itemScrollController.scrollTo(
        index: vState.minImageIndex + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }

  void handOnSliderChangedEnd(double value) {
    final curIndex = vState.currentItemIndex;
    jumpToPage(value.round());
    if ((value.round() - curIndex).abs() > 20) {
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => thumbScrollTo());
    }
  }

  void jumpToPage(int index) {
    vState.currentItemIndex = index;
    if (vState.viewMode != ViewMode.topToBottom) {
      // pageControllerCallBack(() => pageController.jumpToPage(vState.pageIndex),
      //     () => extendedPageController.jumpToPage(vState.pageIndex));
      changePage(vState.pageIndex, animate: false);
    } else {
      itemScrollController.jumpTo(index: vState.currentItemIndex);
      update([idViewTopBar]);
    }
  }

  void handOnSliderChanged(double value) {
    vState.sliderValue = value;
    update([idViewPageSlider]);

    if (vState.syncThumbList) {
      thumbScrollTo(index: value.round());
    }
  }

  void tapShare(BuildContext context) {
    if (vState.loadFrom == LoadFrom.gallery) {
      logger.d('share networkFile ${vState.currentItemIndex + 1}');
      final GalleryImage? p = vState.imageMap?[vState.currentItemIndex + 1];
      logger.d('p:\n${p?.toJson()}');
      showShareActionSheet(
        context,
        imageUrl: p?.imageUrl,
        origImageUrl: p?.originImageUrl,
        filePath: p?.filePath,
      );
    } else {
      logger.d('share localFile');
      showShareActionSheet(
        context,
        filePath: vState.imagePathList[vState.currentItemIndex],
      );
    }
  }

  Future tapAutoRead(BuildContext context, {bool setInv = true}) async {
    // logger.d('tap autoRead');

    if (!vState.autoRead) {
      await _setAutoReadInv(context, setInv: setInv);
      update([idAutoReadIcon]);
      _startAutoRead();
    } else {
      cancelAutoRead();
    }
  }

  Future<void> longTapAutoRead(BuildContext context) async {
    await _setAutoReadInv(context);
    _startAutoRead();
  }

  Future<void> _setAutoReadInv(
    BuildContext context, {
    bool setInv = true,
  }) async {
    final initIndex = EHConst.invList
        .indexWhere((int element) => element == _ehConfigService.turnPageInv);
    final int? inv = setInv
        ? await _showAutoReadInvPicker(
            context,
            EHConst.invList,
            initIndex: initIndex,
          )
        : _ehConfigService.turnPageInv;

    if (inv != null) {
      _ehConfigService.turnPageInv = inv;
      vState.autoRead = !vState.autoRead;
    }
  }

  Future<int?> _showAutoReadInvPicker(BuildContext context, List<int> invList,
      {int? initIndex}) async {
    int _selIndex = initIndex ?? 0;

    final _scrollController =
        FixedExtentScrollController(initialItem: _selIndex);

    final List<Widget> _favPickerList =
        List<Widget>.from(invList.map((int e) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${e / 1000}'),
              ],
            ))).toList();

    return showCupertinoDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Auto page interval'),
          content: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 150,
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 30,
                    onSelectedItemChanged: (int index) {
                      _selIndex = index;
                    },
                    children: _favPickerList,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
              onPressed: () {
                // 返回数据
                Get.back(result: invList[_selIndex]);
              },
            ),
          ],
        );
      },
    );
  }

  void cancelAutoRead() {
    Wakelock.disable();
    vState.autoRead = false;
    vState.lastAutoNextSer = null;
    autoNextTimer?.cancel();
    update([idAutoReadIcon]);
  }

  final debNextPage = Debouncing(duration: const Duration(seconds: 1));

  void _startAutoRead() {
    Wakelock.enable();
    final duration = Duration(milliseconds: _ehConfigService.turnPageInv);
    autoNextTimer = Timer.periodic(duration, (timer) {
      _toPage();
    });
  }

  Future<void> onLoadCompleted(int ser) async {
    vState.loadCompleMap[ser] = true;
    await Future.delayed(const Duration(milliseconds: 100));

    if (vState.autoRead && !(autoNextTimer?.isActive ?? false)) {
      _startAutoRead();
    }
  }

  /// 竖屏阅读下页码变化的监听
  void handItemPositionsChange(Iterable<ItemPosition> positions) {
    int min;
    int max;
    if (positions.isNotEmpty) {
      // Determine the first visible item by finding the item with the
      // smallest trailing edge that is greater than 0.  i.e. the first
      // item whose trailing edge in visible in the viewport.
      min = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      // Determine the last visible item by finding the item with the
      // greatest leading edge that is less than 1.  i.e. the last
      // item whose leading edge in visible in the viewport.
      max = positions
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce((ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
          .index;

      vState.tempIndex = (min + max) ~/ 2;
      // logger.d('max $max  min $min tempIndex ${vState.tempIndex}');

      vState.minImageIndex = min;
      vState.maxImageIndex = max;

      // logger.d('${positions.elementAt(index).itemLeadingEdge} ');
      if (vState.tempIndex != vState.currentItemIndex &&
          vState.conditionItemIndex) {
        // logger.d('${vState.tempIndex} ${vState.currentItemIndex}');
        Future.delayed(const Duration(milliseconds: 200)).then((value) {
          // logger.d('tempIndex ${vState.tempIndex}');
          vState.currentItemIndex = vState.tempIndex;
          vState.sliderValue = vState.currentItemIndex / 1.0;
          update([idViewTopBar, idViewPageSlider]);
          if (vState.syncThumbList) {
            thumbScrollTo();
          }
        });
      }
    }
    // logger.i('First Item: ${min ?? ''}\nLast Item: ${max ?? ''}');
  }

  void handThumbPositionsChange(Iterable<ItemPosition> positions) {
    int? min;
    int? max;
    if (positions.isNotEmpty) {
      min = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      max = positions
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce((ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
          .index;

      final centIndex = (min + max) ~/ 2;
      if (vState.centThumbIndex != centIndex) {
        vState.minThumbIndex = min;
        vState.maxThumbIndex = max;
        vState.centThumbIndex = centIndex;
      }
    }
  }

  final thrThumbScrollTo =
      Throttling(duration: const Duration(milliseconds: 200));

  void thumbScrollTo({int? index}) {
    final indexRange = vState.maxThumbIndex - vState.minThumbIndex;
    final toIndex = index ?? vState.currentItemIndex;
    if (toIndex < vState.filecount - indexRange - 1) {
      thrThumbScrollTo.throttle(() => thumbScrollController.scrollTo(
            index: toIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          ));
    }
  }

  Future<void> _toPage() async {
    if (vState.pageIndex >= vState.pageCount - 1) {
      return;
    }

    if (vState.autoRead) {
      if (vState.viewMode == ViewMode.topToBottom &&
          itemScrollController.isAttached) {
        logger.d('trd minImageIndex:${vState.minImageIndex + 1}');
        final _minIndex = vState.minImageIndex;
        final _minImageSer = _minIndex + 1;
        if (!(vState.loadCompleMap[_minImageSer] ?? false)) {
          autoNextTimer?.cancel();
        }

        vState.lastAutoNextSer = _minImageSer + 1;
        if (!(vState.loadCompleMap[vState.lastAutoNextSer] ?? false)) {
          autoNextTimer?.cancel();
        }

        if (vState.loadCompleMap[_minImageSer] ?? false) {
          itemScrollController.scrollTo(
            index: _minIndex + 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
      } else {
        logger.d('horizontal next page ${vState.pageIndex + 1}');

        if (vState.columnMode == ViewColumnMode.single) {
          // 下一张图片的加载完成标志 如果没有完成 取消翻页定时器
          vState.lastAutoNextSer = vState.currentItemIndex + 2;

          logger.d('cur ${vState.loadCompleMap[vState.currentItemIndex]}  '
              'nex ${vState.loadCompleMap[vState.currentItemIndex + 1]}');

          if (!(vState.loadCompleMap[vState.lastAutoNextSer] ?? false)) {
            autoNextTimer?.cancel();
          }
          // 翻页
          pageControllerCallBack(
            () {
              if (pageController.positions.isNotEmpty) {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              }
            },
            () {
              if (extendedPageController.positions.isNotEmpty) {
                extendedPageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              }
            },
            onPreviewPageController: () {
              if (preloadPageController.positions.isNotEmpty) {
                preloadPageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              }
            },
          );
        } else {
          // 双页阅读
          logger.d('双页阅读 自动翻页');
          final int serLeftNext = vState.serStart + 2;
          if (vState.filecount > serLeftNext) {
            if (serLeftNext > 0 &&
                !(vState.loadCompleMap[serLeftNext] ?? false)) {
              autoNextTimer?.cancel();
            }
            final rigthNextComple =
                vState.loadCompleMap[serLeftNext + 1] ?? false;
            if (!rigthNextComple) {
              autoNextTimer?.cancel();
            }
          }

          final int serLeftCur = vState.serStart;
          if ((vState.loadCompleMap[serLeftCur] ?? false) &&
              (vState.loadCompleMap[serLeftCur + 1] ?? false)) {
            // 翻页
            pageControllerCallBack(
              () {
                if (pageController.positions.isNotEmpty) {
                  pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
              () {
                if (extendedPageController.positions.isNotEmpty) {
                  extendedPageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
              onPreviewPageController: () {
                if (preloadPageController.positions.isNotEmpty) {
                  preloadPageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
            );
          }
        }
      }

      // if (vState.columnMode != ViewColumnMode.single) {
      //   vState.lastAutoNextSer = vState.serStart;
      // }
    }
  }

  static Timer? debounceTimer;

  // 防抖函数
  void vvDebounce(
    Function? doSomething, {
    required String id,
    Duration durationTime = const Duration(milliseconds: 200),
  }) {
    if (debounceTimer?.isActive ?? false) {
      logger.v('timer.cancel');
      debounceTimer?.cancel();
    }

    debounceTimer = Timer(durationTime, () {
      loggerTime.v('func.call');
      doSomething?.call();
      debounceTimer = null;
    });
  }

  Future<void> handOnViewModeChanged(ViewMode val) async {
    final itemIndex = vState.currentItemIndex;
    update([idImagePageView, idViewBottomBar, idIconBar]);
    await Future.delayed(const Duration(milliseconds: 50));
    if (val == ViewMode.topToBottom) {
      itemScrollController.jumpTo(index: itemIndex);
    } else {
      vState.currentItemIndex = itemIndex;
      // pageController.jumpToPage(vState.pageIndex);
      // extendedPageController.jumpToPage(vState.pageIndex);
      // pageControllerCallBack(() => pageController.jumpToPage(vState.pageIndex),
      //     () => extendedPageController.jumpToPage(vState.pageIndex));
      changePage(vState.pageIndex, animate: false);
    }
  }

  void switchSyncThumb() {
    vState.syncThumbList = !vState.syncThumbList;
    if (vState.syncThumbList) {
      thumbScrollTo();
    }
    update([idThumbnailListView]);
  }

  final Map<String, bool> _loadExtendedImageRectComplets = {};

  void handOnLoadCompletExtendedImageRect({required String url}) {
    Future.delayed(const Duration(milliseconds: 50)).then(
      (_) {
        if (!(_loadExtendedImageRectComplets[url] ?? false)) {
          logger.d('onLoadComplet $url');

          _loadExtendedImageRectComplets[url] = true;
          update([idThumbnailListView]);
        }
      },
    );
  }

  void pageControllerCallBack(
    Function onPageController,
    Function onExtendedPageController, {
    Function? onPreviewPageController,
  }) {
    switch (pageViewType) {
      case PageViewType.photoView:
        onPageController.call();
        break;
      case PageViewType.preloadPageview:
        onPreviewPageController?.call();
        break;
      default:
        onExtendedPageController.call();
    }
  }

  void scaleUp() {}

  void scaleDown() {}

  void scaleReset() {}

  Future<void> downloadImage({
    required int ser,
    required String url,
    bool reset = false,
    onError(e)?,
  }) async {
    logger.d('downloadImage $url');
    final savePath = path.join(Global.tempPath, 'ViewTemp', vState.gid, '$ser');

    try {
      await ehDownload(
        savePath: savePath,
        url: url,
        progressCallback: (int count, int total) {
          final process = count / total;
          // loggerSimple.d('ViewTemp download file, $ser $process');
          // _galleryPageController.uptImageProcess(ser, process);
          _galleryPageController?.uptImageBySer(
              ser: ser,
              imageCallback: (image) {
                return image.copyWith(downloadProcess: process);
              });
          update(['${idProcess}_$ser']);
        },
        onDownloadComplete: () {
          _galleryPageController?.uptImageBySer(
              ser: ser,
              imageCallback: (image) => image.copyWith(
                    tempPath: savePath,
                    completeCache: true,
                    changeSource: false,
                  ));
        },
      );
    } catch (e) {
      onError?.call(e);
      // logger.e('$e');
      // logger.e('${e.runtimeType}');
      // _galleryPageController.uptImageBySer(
      //     ser: ser, imageCallback: (image) => image.copyWith(errorInfo: '$e'));
      // update(['${idProcess}_$ser']);
    }
  }
}
