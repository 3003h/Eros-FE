import 'dart:async';
import 'dart:io';

import 'package:archive_async/archive_async.dart';
import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/store/archive_async.dart';
import 'package:fehviewer/utils/orientation_helper.dart';
import 'package:fehviewer/utils/saf_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:saf/saf.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:synchronized/synchronized.dart';
import 'package:throttling/throttling.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'view_state.dart';

// 底栏控制栏按钮高度
const double kBottomBarButtonHeight = 54.0;

// 底栏控制栏高度
const double kBottomBarHeight = 64.0;

// 底栏滑动栏高度
const double kSliderBarHeight = 64.0;

// 顶栏高度
const double kTopBarHeight = 56.0;

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
  preloadPhotoView,
  preloadPageView,
  extendedImageGesturePageView,
}

/// 支持在线以及本地（已下载）阅读的组件
class ViewExtController extends GetxController {
  ViewExtController();

  /// 状态
  final ViewExtState vState = ViewExtState();

  final _absorbing = false.obs;
  bool get absorbing => _absorbing.value;
  set absorbing(bool val) => _absorbing.value = val;

  late PageController pageController;
  late ExtendedPageController extendedPageController;

  late PreloadPageController preloadPageController;

  GalleryPageController? get _galleryPageController =>
      vState.galleryPageController;

  GalleryPageState? get _galleryPageStat => vState.pageState;

  EhSettingService get _ehSettingService => vState.ehSettingService;

  late final ArchiverDownloadController archiverDownloadController;

  // 使用 PhotoView
  PageViewType get pageViewType => _ehSettingService.readViewCompatibleMode
      ? PageViewType.extendedImageGesturePageView
      : PageViewType.preloadPageView;

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

  StreamSubscription? _volumeKeyDownSubscription;

  String? safCacheDirectory;

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<ArchiverDownloadController>()) {
      archiverDownloadController = Get.find();
    }

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
      // logger.t('竖屏模式初始页码: ${vState.itemIndex}');
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

    addVolumeKeydownListen();
  }

  @override
  void onReady() {
    super.onReady();

    logger.t('Read onReady');

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    if (vState.loadFrom == LoadFrom.gallery) {
      // 预载
      logger.t('初始预载');

      GalleryPara.instance
          .ehPrecacheImages(
        imageMap: vState.imageMap,
        itemSer: vState.currentItemIndex,
        max: _ehSettingService.preloadImage.value,
        showKey: vState.pageState?.galleryProvider?.showKey,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController?.uptImageBySer(
              ser: event.ser, imageCallback: (image) => event);
        }
      });
    }

    logger.t('旋转设置');
    final ReadOrientation? _orientation = _ehSettingService.orientation.value;
    // logger.d(' $_orientation');
    if (_orientation != ReadOrientation.system &&
        _orientation != ReadOrientation.auto) {
      OrientationHelper.setPreferredOrientations(
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

    cancelVolumeKeydownListen();

    // unsetFullscreen();
    400.milliseconds.delay(() => unsetFullscreen());

    // 恢复系统旋转设置
    logger.t('恢复系统旋转设置');
    OrientationHelper.setPreferredOrientations(DeviceOrientation.values);

    vState.asyncInputStreamMap.values.map((e) => e.close());

    if (safCacheDirectory != null) {
      Saf.clearCacheFor(safCacheDirectory);
      safCacheDirectory = null;
    }

    super.onClose();
  }

  void addVolumeKeydownListen() {
    if (_ehSettingService.volumnTurnPage) {
      _volumeKeyDownSubscription =
          FlutterAndroidVolumeKeydown.stream.listen((event) {
        if (event == HardwareButton.volume_down) {
          // logger.d('Volume down received');
          toNext();
        } else if (event == HardwareButton.volume_up) {
          // logger.d('Volume up received');
          toPrev();
        }
      });
    }
  }

  void cancelVolumeKeydownListen() {
    _volumeKeyDownSubscription?.cancel();
  }

  Future<void> initArchiveFuture(int ser, {AsyncArchiveFile? asyncFile}) async {
    final file = asyncFile ?? vState.asyncArchiveFiles[ser - 1];
    logger.t('load ${file.name}');
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
      // logger.t('页码切换时的回调 预载图片');
      GalleryPara.instance
          .ehPrecacheImages(
        imageMap: _galleryPageStat?.imageMap,
        itemSer: vState.currentItemIndex,
        max: _ehSettingService.preloadImage.value,
        showKey: vState.pageState?.galleryProvider?.showKey,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController?.uptImageBySer(
              ser: event.ser, imageCallback: (val) => event);
        }
      });
    }

    if (vState.currentItemIndex >= vState.fileCount - 1) {
      vState.sliderValue = (vState.fileCount - 1).toDouble();
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
    logger.t('切换单页双页模式');
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
    bool reloadDB = false,
  }) async {
    if (dir == null) {
      return null;
    }

    if (reloadDB) {
      vState.imageTasks = await isarHelper.findImageTaskAllByGidIsolate(
          int.tryParse(_galleryPageStat?.gid ?? '') ?? 0);
    }

    final imageTask = vState.imageTasks
        .firstWhereOrNull((imageTask) => imageTask.ser == itemSer);

    if (imageTask != null &&
        imageTask.filePath != null &&
        imageTask.filePath!.isNotEmpty &&
        imageTask.status == TaskStatus.complete.value) {
      final filePath = dir.isContentUri
          ? '$dir%2F${imageTask.filePath}'
          : path.join(dir, imageTask.filePath!);

      return GalleryImage(
        ser: itemSer,
        completeDownload: true,
        filePath: filePath,
      );
    }
    return null;
  }

  Future<String?> _getTaskDirPath(int gid) async {
    logger.d('vState.realDirPath ${vState.realDirPath} gid:${vState.gid} $gid');
    if (vState.gid == gid.toString() &&
        vState.realDirPath != null &&
        vState.realDirPath!.isNotEmpty) {
      return vState.realDirPath;
    }

    final gTask = await isarHelper.findGalleryTaskByGid(gid);

    final realDirPath = gTask?.realDirPath;
    if (realDirPath != null && realDirPath.isNotEmpty) {
      vState.realDirPath = realDirPath;
    }

    return gTask?.realDirPath;
  }

  /// 拉取图片信息
  Future<GalleryImage?> fetchImage(
    int itemSer, {
    bool changeSource = false,
  }) async {
    logger.d('fetchImage ser:$itemSer');

    // 首先检查下载记录中是否有记录
    vState.dirPath ??=
        await _getTaskDirPath(int.tryParse(_galleryPageStat?.gid ?? '') ?? 0);

    late GalleryImage? image;

    // 检查是否已下载
    image = await _getImageFromImageTasks(itemSer, vState.dirPath);
    image ??=
        await _getImageFromImageTasks(itemSer, vState.dirPath, reloadDB: true);
    if (image != null) {
      logger.d('fetchImage ser:$itemSer 从下载记录中获取');
      return image;
    }

    // 检查是否已下载archive
    if (GetPlatform.isMobile) {
      image ??= await getFromArchiverTask(itemSer);
    }

    // 请求页面 解析为 [GalleryImage]
    if (image == null) {
      final tImage = _galleryPageStat?.imageMap[itemSer];
      if (tImage == null) {
        logger.d('ser:$itemSer 所在页尚未获取， 开始获取');

        // 直接获取所在页数据
        await _galleryPageController?.loadImagesForSer(itemSer);
      }

      var needShowKey =
          vState.pageState?.galleryProvider?.showKey?.isEmpty ?? true;
      
      if (needShowKey) {
        // fetchAndParserImageInfo() then ehPrecacheImages()
        // make sure showKey is parsed before ehPrecacheImages()
        image = await _galleryPageController?.fetchAndParserImageInfo(
        itemSer,
        cancelToken: vState.getMoreCancelToken,
        changeSource: changeSource,
        );
      }

      GalleryPara.instance
          .ehPrecacheImages(
        imageMap: _galleryPageStat?.imageMap,
        itemSer: itemSer,
        max: _ehSettingService.preloadImage.value,
        showKey: vState.pageState?.galleryProvider?.showKey,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController?.uptImageBySer(
              ser: event.ser, imageCallback: (val) => val = event);
        }
      });

      if (!needShowKey) {
        // ehPrecacheImages() then fetchAndParserImageInfo()
        // the original logic
        image = await _galleryPageController?.fetchAndParserImageInfo(
        itemSer,
        cancelToken: vState.getMoreCancelToken,
        changeSource: changeSource,
        );
      }

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
              element.status ==
                  downloadStatusToInt(DownloadTaskStatus.complete))
          .toList()
          .firstOrNull;

      if (task == null) {
        return null;
      }

      // final filePath = path.join(task.savedDir ?? '', task.fileName);
      late final String? filePath;
      if (task.savedDir?.isContentUri ?? false) {
        final _uri = task.safUri ??
            '${task.savedDir}%2F${Uri.encodeComponent(task.fileName ?? '')}';
        final result = await safCacheSingle(Uri.parse(_uri));
        filePath = result.cachePath;
        safCacheDirectory = result.parentPath;
      } else {
        filePath = path.join(task.savedDir ?? '', task.fileName);
      }
      // logger.d('filePath $filePath');
      if (filePath == null) {
        throw Exception('filePath is null');
      }

      // 异步读取zip
      final result = await readAsyncArchive(filePath.realArchiverPath);
      final asyncArchive = result.asyncArchive;
      final asyncInputStream = result.asyncInputStream;
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
    update(['$idImageListView$itemSer', idImagePageView]);
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
    if (_ehSettingService.viewFullscreen) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    }
  }

  Future<void> unsetFullscreen() async {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  void changePage(
    int page, {
    Duration duration = const Duration(milliseconds: 200),
    bool? animate,
  }) {
    final enableAnimate = animate ?? _ehSettingService.turnPageAnimations;

    if (enableAnimate) {
      // 竖向卷轴模式
      if (vState.viewMode == ViewMode.topToBottom) {
        itemScrollController.scrollTo(
          index: page,
          duration: duration,
          curve: Curves.ease,
        );
        return;
      }

      // 横向翻页模式
      switch (pageViewType) {
        case PageViewType.photoView:
          pageController.animateToPage(
            page,
            duration: duration,
            curve: Curves.ease,
          );
          break;
        case PageViewType.preloadPageView: // 预载模式（不启用兼容时）
          preloadPageController.animateToPage(
            page,
            duration: duration,
            curve: Curves.ease,
          );
          break;
        default:
          if (vState.columnMode == ViewColumnMode.single) {
            // 单页模式 使用 extendedImageGesturePageView
            extendedPageController.animateToPage(
              page,
              duration: duration,
              curve: Curves.ease,
            );
          } else {
            // 双页模式 实际还是使用preloadPageView
            preloadPageController.animateToPage(
              page,
              duration: duration,
              curve: Curves.ease,
            );
          }
      }
    } else {
      // 竖向卷轴模式
      if (vState.viewMode == ViewMode.topToBottom) {
        itemScrollController.jumpTo(
          index: page,
        );
        return;
      }

      // 横向翻页模式
      switch (pageViewType) {
        case PageViewType.photoView:
          pageController.jumpToPage(page);
          break;
        case PageViewType.preloadPageView:
          preloadPageController.jumpToPage(page);
          break;
        default:
          // extendedPageController.jumpToPage(page);
          if (vState.columnMode == ViewColumnMode.single) {
            // 单页模式 使用 extendedImageGesturePageView
            extendedPageController.jumpToPage(page);
          } else {
            // 双页模式 实际还是使用preloadPageView
            preloadPageController.jumpToPage(page);
          }
      }
    }
  }

  Future<void> tapLeft() async {
    logger.t('${vState.viewMode} tap left');
    final enableAnimate = _ehSettingService.turnPageAnimations;
    vState.fade = false;

    // if (vState.viewMode == ViewMode.LeftToRight && vState.pageIndex > 0) {
    //   final toPage = vState.pageIndex - 1;
    //   changePage(toPage);
    // } else if (vState.viewMode == ViewMode.rightToLeft &&
    //     vState.pageIndex < vState.filecount) {
    //   final toPage = vState.pageIndex + 1;
    //   changePage(toPage);
    // } else if (vState.viewMode == ViewMode.topToBottom &&
    //     itemScrollController.isAttached &&
    //     !vState.isScrolling &&
    //     vState.pageIndex > 0) {
    //   logger.t('${vState.minImageIndex}');
    //   itemScrollController.scrollTo(
    //     index: vState.minImageIndex - 1,
    //     duration: const Duration(milliseconds: 200),
    //     curve: Curves.ease,
    //   );
    // }

    if (vState.viewMode == ViewMode.leftToRight) {
      toPrev();
    } else if (vState.viewMode == ViewMode.rightToLeft) {
      toNext();
    } else if (vState.viewMode == ViewMode.topToBottom) {
      if (itemScrollController.isAttached && !vState.isScrolling) {
        toPrev();
      }
    }
  }

  Future<void> tapRight() async {
    logger.t('${vState.viewMode} tap right');
    vState.fade = false;
    // if (vState.viewMode == ViewMode.LeftToRight &&
    //     vState.pageIndex < vState.filecount) {
    //   final toPage = vState.pageIndex + 1;
    //   changePage(toPage);
    // } else if (vState.viewMode == ViewMode.rightToLeft &&
    //     vState.pageIndex > 0) {
    //   final toPage = vState.pageIndex - 1;
    //   changePage(toPage);
    // } else if (vState.viewMode == ViewMode.topToBottom &&
    //     itemScrollController.isAttached &&
    //     !vState.isScrolling &&
    //     vState.pageIndex < vState.filecount) {
    //   itemScrollController.scrollTo(
    //     index: vState.minImageIndex + 1,
    //     duration: const Duration(milliseconds: 200),
    //     curve: Curves.ease,
    //   );
    // }

    if (vState.viewMode == ViewMode.leftToRight) {
      toNext();
    } else if (vState.viewMode == ViewMode.rightToLeft) {
      toPrev();
    } else if (vState.viewMode == ViewMode.topToBottom &&
        itemScrollController.isAttached &&
        !vState.isScrolling) {
      toNext();
    }
  }

  void toNext() {
    if (vState.viewMode == ViewMode.topToBottom &&
        itemScrollController.isAttached &&
        !vState.isScrolling &&
        vState.pageIndex < vState.fileCount - 1) {
      itemScrollController.scrollTo(
        index: vState.minImageIndex + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    } else if (vState.pageIndex < vState.fileCount - 1) {
      final toPage = vState.pageIndex + 1;
      changePage(toPage);
    }
  }

  void toPrev() {
    if (vState.viewMode == ViewMode.topToBottom &&
        itemScrollController.isAttached &&
        !vState.isScrolling &&
        vState.pageIndex > 0) {
      itemScrollController.scrollTo(
        index: vState.minImageIndex - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    } else if (vState.pageIndex > 0) {
      final toPage = vState.pageIndex - 1;
      changePage(toPage);
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
    final ser = vState.currentItemIndex + 1;
    if (vState.loadFrom == LoadFrom.gallery) {
      logger.d('share networkFile $ser');
      final GalleryImage? p = vState.imageMap?[ser];
      logger.d('p:\n${p?.toJson()}');
      showShareActionSheet(
        context,
        imageUrl: p?.imageUrl,
        origImageUrl: p?.originImageUrl,
        filePath: p?.filePath,
        gid: vState.gid,
        ser: ser,
        filename: p?.filename,
      );
    } else {
      logger.d('share localFile');
      showShareActionSheet(
        context,
        isLocal: true,
        filePath: vState.imagePathList[vState.currentItemIndex],
        gid: vState.gid,
        ser: ser,
      );
    }
  }

  void tapSave(BuildContext context) {
    final ser = vState.currentItemIndex + 1;
    if (vState.loadFrom == LoadFrom.gallery) {
      logger.d('save networkFile ser');
      final GalleryImage? p = vState.imageMap?[ser];
      logger.d('p:\n${p?.toJson()}');
      showSaveActionSheet(
        context,
        imageUrl: p?.imageUrl,
        origImageUrl: p?.originImageUrl,
        filePath: p?.filePath,
        gid: vState.gid,
        ser: ser,
        filename: p?.filename,
      );
    } else {
      logger.d('save localFile');
      showSaveActionSheet(
        context,
        isLocal: true,
        filePath: vState.imagePathList[vState.currentItemIndex],
        gid: vState.gid,
        ser: ser,
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
        .indexWhere((int element) => element == _ehSettingService.turnPageInv);
    final int? inv = setInv
        ? await _showAutoReadInvPicker(
            context,
            EHConst.invList,
            initIndex: initIndex,
          )
        : _ehSettingService.turnPageInv;

    if (inv != null) {
      _ehSettingService.turnPageInv = inv;
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
    WakelockPlus.disable();
    vState.autoRead = false;
    vState.lastAutoNextSer = null;
    autoNextTimer?.cancel();
    update([idAutoReadIcon]);
  }

  final debNextPage = Debouncing(duration: const Duration(seconds: 1));

  void _startAutoRead() {
    WakelockPlus.enable();
    final duration = Duration(milliseconds: _ehSettingService.turnPageInv);
    autoNextTimer = Timer.periodic(duration, (timer) {
      _autoTunToPage();
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
    if (toIndex < vState.fileCount - indexRange - 1) {
      thrThumbScrollTo.throttle(() => thumbScrollController.scrollTo(
            index: toIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          ));
    }
  }

  Future<void> _autoTunToPage() async {
    if (vState.pageIndex >= vState.pageCount - 1) {
      return;
    }

    if (vState.autoRead) {
      if (vState.viewMode == ViewMode.topToBottom &&
          itemScrollController.isAttached) {
        logger.d('t2d minImageIndex:${vState.minImageIndex + 1}');
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
          changePage(_minIndex + 1);
        }
      } else {
        changePage(vState.pageIndex + 1);
      }
    }
  }

  Future<void> _autoTunToPage_Old() async {
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
          // itemScrollController.scrollTo(
          //   index: _minIndex + 1,
          //   duration: const Duration(milliseconds: 200),
          //   curve: Curves.ease,
          // );
          changePage(_minIndex + 1);
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
          final int serLeftNext = vState.serFirst + 2;
          if (vState.fileCount > serLeftNext) {
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

          final int serLeftCur = vState.serFirst;
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
      logger.t('timer.cancel');
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
      case PageViewType.preloadPageView:
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
