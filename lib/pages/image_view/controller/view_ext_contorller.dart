import 'dart:async';

import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:throttling/throttling.dart';

import 'view_ext_state.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 44.0;
const double kThumbListViewHeight = 120.0;

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

const int _speedMaxCount = 50;
const int _speedInv = 10;

/// 支持在线以及本地（已下载）阅读的组件
class ViewExtController extends GetxController {
  /// 状态
  final ViewExtState vState = ViewExtState();

  late PageController pageController;

  GalleryPageController get _galleryPageController =>
      vState.galleryPageController;
  EhConfigService get _ehConfigService => vState.ehConfigService;

  Map<int, Future<GalleryImage?>> imageFutureMap = {};

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController thumbScrollController = ItemScrollController();
  final ItemPositionsListener thumbPositionsListener =
      ItemPositionsListener.create();

  final AutoScrollController autoScrollController = AutoScrollController();
  final photoViewScaleStateController = PhotoViewScaleStateController();

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

    Future.delayed(const Duration(milliseconds: 100)).then((value) =>
        thumbScrollController.jumpTo(index: vState.currentItemIndex));

    // 缩略图滚动组件监听
    thumbPositionsListener.itemPositions.addListener(() {
      final positions = thumbPositionsListener.itemPositions.value;
      handThumbPositionsChange(positions);
    });

    photoViewScaleStateController.outputScaleStateStream.listen((state) {
      final prevScaleState = photoViewScaleStateController.prevScaleState;
      logger.d('prevScaleState $prevScaleState , state $state');
    });

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    if (vState.loadType == LoadType.network) {
      // 预载
      logger.v('初始预载');
      GalleryPara.instance
          .precacheImages(
        Get.context!,
        imageMap: vState.imageMap,
        itemSer: vState.currentItemIndex,
        max: _ehConfigService.preloadImage.value,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          // logger5.d('preloadImage upt previewMap ${event.ser}');
          _galleryPageController.uptImageBySer(ser: event.ser, image: event);
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
      // OrientationPlugin.forceOrientation(
      //     orientationMap[_orientation] ?? DeviceOrientation.portraitUp);
    }

    vState.sliderValue = vState.currentItemIndex / 1.0;

    if (GetPlatform.isIOS) {
      FlutterStatusbarManager.setFullscreen(true);
    }
    // FlutterStatusbarManager.setHidden(true,
    //     animation: StatusBarAnimation.SLIDE);
    // FlutterStatusbarManager.setTranslucent(true);
    // FlutterStatusbarManager.setColor(Colors.transparent);
  }

  @override
  void onClose() {
    super.onClose();
    cancelAutoRead();
    autoNextTimer?.cancel();
    autoNextTimer = null;

    vState.speedTimer?.cancel();
    Get.find<GalleryCacheController>().saveAll();
    vState.saveLastIndex(saveToStore: true);
    pageController.dispose();
    vState.getMoreCancelToken.cancel();

    FlutterStatusbarManager.setHidden(false,
        animation: StatusBarAnimation.SLIDE);
    FlutterStatusbarManager.setFullscreen(false);
    FlutterStatusbarManager.setTranslucent(false);

    // 恢复系统旋转设置
    logger.v('恢复系统旋转设置');
    OrientationPlugin.setPreferredOrientations(DeviceOrientation.values);
    // OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
  }

  void resetPageController() {
    pageController = PageController(
      initialPage: pageController.positions.isNotEmpty
          ? pageController.page?.round() ?? vState.currentItemIndex
          : vState.currentItemIndex,
      viewportFraction: vState.showPageInterval ? 1.1 : 1.0,
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

    if (vState.loadType == LoadType.network) {
      // 预载图片
      // logger.v('页码切换时的回调 预载图片');
      GalleryPara.instance
          .precacheImages(
        Get.context!,
        imageMap: _galleryPageController.imageMap,
        itemSer: vState.currentItemIndex,
        max: _ehConfigService.preloadImage.value,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          _galleryPageController.uptImageBySer(ser: event.ser, image: event);
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
    pageController.jumpToPage(_toIndex);
  }

  Future<void> switchShowThumbList() async {
    if (vState.showThumbList) {
      vState.showThumbList = false;
    } else {
      vState.showThumbList = true;
    }

    update([idShowThumbListIcon, idViewBottomBar, idThumbnailListView]);
  }

  final Map<int, Future<void>> _mapFetchGalleryPriviewPage = {};

  /// 拉取图片信息
  Future<GalleryImage?> fetchThumb(
    int itemSer, {
    bool refresh = false,
    bool changeSource = false,
  }) async {
    final GalleryImage? tImage = _galleryPageController.imageMap[itemSer];
    if (tImage == null) {
      logger.d('fetchThumb ser:$itemSer 所在页尚未获取， 开始获取');
      _mapFetchGalleryPriviewPage.putIfAbsent(
          itemSer, () => _galleryPageController.loadImagesForSer(itemSer));

      // 直接获取需要的ser所在页
      await _mapFetchGalleryPriviewPage[itemSer];
    }

    final GalleryImage? image = _galleryPageController.imageMap[itemSer];

    return image;
  }

  GalleryImage? _getImageFromImageTasks(int itemSer, String? dir) {
    if (dir == null) {
      return null;
    }

    final imageTask = vState.imageTasks
        .firstWhereOrNull((imageTask) => imageTask.ser == itemSer);

    if (imageTask != null &&
        imageTask.filePath != null &&
        imageTask.filePath!.isNotEmpty &&
        imageTask.status == TaskStatus.complete.value) {
      return GalleryImage(
        ser: itemSer,
        isDownloaded: true,
        filePath: path.join(dir, imageTask.filePath!),
      );
    }
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
    vState.imageTaskDao ??= await DownloadController.getImageTaskDao();
    vState.galleryTaskDao ??= await DownloadController.getGalleryTaskDao();
    vState.dirPath ??=
        await _getTaskDirPath(int.parse(_galleryPageController.gid));

    // logger.d('${vState.dirPath}');

    GalleryImage? imageFromTasks =
        _getImageFromImageTasks(itemSer, vState.dirPath);
    if (imageFromTasks != null) {
      return imageFromTasks;
    }

    vState.imageTasks = await vState.imageTaskDao!
        .findAllTaskByGid(int.parse(_galleryPageController.gid));

    imageFromTasks = _getImageFromImageTasks(itemSer, vState.dirPath);
    if (imageFromTasks != null) {
      return imageFromTasks;
    }

    final tImage = _galleryPageController.imageMap[itemSer];
    if (tImage == null) {
      logger.d('ser:$itemSer 所在页尚未获取， 开始获取');

      // 直接获取需要的
      await _galleryPageController.loadImagesForSer(itemSer);
    }

    GalleryPara.instance
        .precacheImages(
      Get.context!,
      imageMap: _galleryPageController.imageMap,
      itemSer: itemSer,
      max: _ehConfigService.preloadImage.value,
    )
        .listen((GalleryImage? event) {
      if (event != null) {
        _galleryPageController.uptImageBySer(ser: event.ser, image: event);
      }
    });

    final GalleryImage? image =
        await _galleryPageController.fetchAndParserImageInfo(
      itemSer,
      cancelToken: vState.getMoreCancelToken,
      // refresh: refresh,
      changeSource: changeSource,
    );

    return image;
  }

  /// 重载图片数据，重构部件
  Future<void> reloadImage(int itemSer, {bool changeSource = true}) async {
    final GalleryImage? _currentImage =
        _galleryPageController.galleryItem.imageMap[itemSer];
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
    _galleryPageController.uptImageBySer(
      ser: itemSer,
      image: _currentImage.copyWith(imageUrl: ''),
    );

    // 换源重载
    imageFutureMap[itemSer] = fetchImage(
      itemSer,
      // refresh: true,
      changeSource: changeSource,
    );

    update();
  }

  void setScale100(ImageInfo imageInfo, Size size) {
    final sizeImage = Size(
        imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());

    // logger.d('sizeImage $sizeImage\nsize $size');

    final double _scalesS100 = scale100(size: size, imageSize: sizeImage);

    // logger.d('_scalesScreen $_scalesScreen');
    // logger.d('_scalesS100 $_scalesS100');
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

    if (GetPlatform.isIOS) {
      if (!vState.showBar) {
        // show
        FlutterStatusbarManager.setFullscreen(false);
        vState.showBar = !vState.showBar;
        update([idViewBar]);
      } else {
        // hide
        vState.showBar = !vState.showBar;
        update([idViewBar]);
        // await Future.delayed(const Duration(milliseconds: 200));
        FlutterStatusbarManager.setFullscreen(true);
        // FlutterStatusbarManager.setHidden(true);
      }
    } else {
      vState.showBar = !vState.showBar;
      update([idViewBar]);
    }
  }

  Future<void> tapLeft() async {
    logger.v('${vState.viewMode} tap left');
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight && vState.pageIndex > 0) {
      pageController.animateToPage(vState.pageIndex - 1,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } else if (vState.viewMode == ViewMode.rightToLeft &&
        vState.pageIndex < vState.filecount) {
      pageController.animateToPage(vState.pageIndex + 1,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } else if (vState.viewMode == ViewMode.topToBottom &&
        itemScrollController.isAttached &&
        !vState.isScrolling &&
        vState.pageIndex > 0) {
      logger.d('${vState.minImageIndex}');
      itemScrollController.scrollTo(
        // index: vState.pageIndex - 1,
        index: vState.minImageIndex - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }

  Future<void> tapRight() async {
    // logger.d('${vState.speedList}');

    logger.v('${vState.viewMode} tap right');
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight &&
        vState.pageIndex < vState.filecount) {
      // pageController.jumpToPage(vState.pageIndex + 1);
      pageController.animateToPage(vState.pageIndex + 1,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } else if (vState.viewMode == ViewMode.rightToLeft &&
        vState.pageIndex > 0) {
      // pageController.jumpToPage(vState.pageIndex - 1);
      pageController.animateToPage(vState.pageIndex - 1,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
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
      pageController.jumpToPage(vState.pageIndex);
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

  void share(BuildContext context) {
    if (vState.loadType == LoadType.network) {
      final GalleryImage? p =
          _galleryPageController.imageMap[vState.currentItemIndex + 1];
      logger.v(p?.toJson());
      showShareActionSheet(
        context,
        imageUrl: p?.imageUrl,
      );
    } else {
      showShareActionSheet(
        context,
        filePath: vState.imagePathList[vState.currentItemIndex],
      );
    }
  }

  Future tapAutoRead(BuildContext context) async {
    // logger.d('tap autoRead');

    if (!vState.autoRead) {
      await _setAutoReadInv(context);
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

  Future<void> _setAutoReadInv(BuildContext context) async {
    // logger.d('_ehConfigService.turnPageInv ${_ehConfigService.turnPageInv}');

    final initIndex = EHConst.invList
        .indexWhere((int element) => element == _ehConfigService.turnPageInv);
    final int? inv = await _showAutoReadInvPicker(
      context,
      EHConst.invList,
      initIndex: initIndex,
    );

    if (inv != null) {
      // logger.d('set inv $inv');
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
    vState.autoRead = false;
    vState.lastAutoNextSer = null;
    autoNextTimer?.cancel();
    update([idAutoReadIcon]);
  }

  final debNextPage = Debouncing(duration: const Duration(seconds: 1));
  void _startAutoRead() {
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
        logger.v('trd minImageIndex:${vState.minImageIndex + 1}');
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
        logger.d('ltr or rtl next page ${vState.pageIndex + 1}');

        if (vState.columnMode == ViewColumnMode.single) {
          // 下一张图片的加载完成标志 如果没有完成 取消翻页定时器
          vState.lastAutoNextSer = vState.minImageIndex + 2;
          if (!(vState.loadCompleMap[vState.lastAutoNextSer] ?? false)) {
            autoNextTimer?.cancel();
          }
          // 翻页
          if (pageController.positions.isNotEmpty) {
            pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        } else {
          // 双页阅读
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
            if (pageController.positions.isNotEmpty) {
              pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut);
            }
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
      pageController.jumpToPage(vState.pageIndex);
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
}
