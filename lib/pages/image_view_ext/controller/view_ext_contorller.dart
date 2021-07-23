import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view_ext/common.dart';
import 'package:fehviewer/pages/image_view_ext/view/view_ext.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';

import 'view_ext_state.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 44.0;

const String idViewTopBar = 'ViewExtController.ViewTopBar';
const String idViewBottomBar = 'ViewExtController.ViewBottomBar';
const String idViewBar = 'ViewExtController.ViewBar';
const String idViewPageSlider = 'ViewExtController.ViewPageSlider';
const String idPageView = 'ViewExtController.ExtendedImageGesturePageView';
const String idViewColumnModeIcon = 'ViewExtController.ViewColumnModeIcon';
const String idAutoReadIcon = 'ViewExtController.AutoReadIcon';

/// 支持在线以及本地（已下载）阅读的组件
class ViewExtController extends GetxController {
  /// 状态
  final ViewExtState vState = ViewExtState();

  late PageController pageController;

  GalleryPageController get _galleryPageController =>
      vState.galleryPageController;
  EhConfigService get _ehConfigService => vState.ehConfigService;

  final GalleryCacheController _galleryCacheController = Get.find();

  // todo 双页阅读会有问题
  // late Future<GalleryImage?> imageFuture;

  Map<int, Future<GalleryImage?>> imageFutureMap = {};

  @override
  void onInit() {
    super.onInit();

    // 横屏模式pageview控制器初始化
    pageController = PageController(
      initialPage: vState.currentItemIndex,
      viewportFraction: vState.showPageInterval ? 1.1 : 1.0,
    );

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    final int _preload = _ehConfigService.preloadImage.value;
    if (1 == 1) {
      // 预载
      logger.v('初始预载');
      GalleryPara.instance
          .precacheImages(
        Get.context!,
        imageMap: vState.imageMap,
        itemSer: vState.currentItemIndex,
        max: _preload,
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
    logger.d(' $_orientation');
    if (_orientation != ReadOrientation.system &&
        _orientation != ReadOrientation.auto) {
      OrientationPlugin.setPreferredOrientations(
          [orientationMap[_orientation] ?? DeviceOrientation.portraitUp]);
      // OrientationPlugin.forceOrientation(
      //     orientationMap[_orientation] ?? DeviceOrientation.portraitUp);
    }

    vState.sliderValue = vState.currentItemIndex / 1.0;
  }

  @override
  void onClose() {
    Get.find<GalleryCacheController>().saveAll();
    pageController.dispose();
    vState.getMoreCancelToken.cancel();
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    FlutterStatusbarManager.setFullscreen(false);
    // 恢复系统旋转设置
    logger.d('恢复系统旋转设置');
    OrientationPlugin.setPreferredOrientations(DeviceOrientation.values);
    // OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    cancelAutoRead();

    super.onClose();
  }

  void resetPageController() {
    pageController = PageController(
      initialPage: pageController.page?.round() ?? vState.currentItemIndex,
      viewportFraction: vState.showPageInterval ? 1.1 : 1.0,
    );
  }

  // 页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    logger.d('PageChanged $pageIndex');

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
  }

  /// 切换单页双页模式
  void switchColumnMode() {
    vibrateUtil.light();
    logger.v('切换单页双页模式');
    switch (vState.columnMode) {
      case ViewColumnMode.single:
        logger.d('单页 => 双页1. itemIndex:${vState.currentItemIndex},');
        vState.columnMode = ViewColumnMode.oddLeft;
        pageController.jumpToPage(vState.pageIndex);
        update([idViewColumnModeIcon, idPageView]);
        break;
      case ViewColumnMode.oddLeft:
        logger.d('双页1 => 双页2, itemIndex:${vState.currentItemIndex}');
        vState.columnMode = ViewColumnMode.evenLeft;
        vState.needRebuild = true;
        update([idViewColumnModeIcon, idPageView]);
        pageController.jumpToPage(vState.pageIndex);
        break;
      case ViewColumnMode.evenLeft:
        logger.d('双页2 => 单页, itemIndex:${vState.currentItemIndex}');
        vState.columnMode = ViewColumnMode.single;
        Future.delayed(Duration.zero).then((_) {
          final int _toIndex = vState.pageIndex;
          logger.d('pageIndex $_toIndex');
          vState.currentItemIndex = _toIndex;
          vState.sliderValue = _toIndex.toDouble();
          update([idViewColumnModeIcon, idPageView]);
          pageController.jumpToPage(_toIndex);
        });
        break;
    }
  }

  /// 拉取图片信息
  Future<GalleryImage?> fetchImage(
    int itemSer, {
    bool refresh = false,
    bool changeSource = false,
  }) async {
    final GalleryImage? tImage = _galleryPageController.imageMap[itemSer];
    if (tImage == null) {
      logger.d('ser:$itemSer 所在页尚未获取， 开始获取');

      // 直接获取需要的
      await _galleryPageController.loadImagesForSer(itemSer);

      // logger.v('获取缩略结束后 预载图片');
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
    }

    final GalleryImage? image = await _galleryPageController.getImageInfo(
      itemSer,
      cancelToken: vState.getMoreCancelToken,
      refresh: refresh,
      changeSource: changeSource,
    );
    if (image != null) {
      _galleryPageController.uptImageBySer(ser: image.ser, image: image);
    }

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
      refresh: true,
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
    if (GetPlatform.isIOS) {
      if (!vState.showBar) {
        await FlutterStatusbarManager.setFullscreen(false);
        vState.showBar = !vState.showBar;
      } else {
        vState.showBar = !vState.showBar;
        await Future.delayed(Duration(milliseconds: 200));
        await FlutterStatusbarManager.setFullscreen(true);
      }
    } else {
      vState.showBar = !vState.showBar;
    }
    update([idViewBar]);
  }

  Future<void> tapLeft() async {
    logger.d('tap left');
  }

  Future<void> tapRight() async {
    logger.d('tap right');
  }

  void handOnSliderChangedEnd(double value) {
    vState.currentItemIndex = value.round();
    // TODO(honjow): 上下滚动模式
    pageController.jumpToPage(vState.pageIndex);
  }

  void handOnSliderChanged(double value) {
    vState.sliderValue = value;
    update([idViewPageSlider]);
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
    logger.d('tap autoRead');

    if (!vState.autoRead) {
      await _setAutoReadInv(context);
    } else {
      vState.autoRead = !vState.autoRead;
    }
    update([idAutoReadIcon]);

    _startAutoRead();
  }

  Future<void> longTapAutoRead(BuildContext context) async {
    await _setAutoReadInv(context);
    _startAutoRead();
  }

  Future<void> _setAutoReadInv(BuildContext context) async {
    logger.d('_ehConfigService.turnPageInv ${_ehConfigService.turnPageInv}');

    final initIndex = EHConst.invList
        .indexWhere((int element) => element == _ehConfigService.turnPageInv);
    final int? inv = await _showAutoReadInvPicker(
      context,
      EHConst.invList,
      initIndex: initIndex,
    );

    if (inv != null) {
      logger.d('set inv $inv');
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
          title: const Text('自动翻页间隔'),
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
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
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
    update([idAutoReadIcon]);
  }

  void _startAutoRead() {
    vDebounceM(
      _turnNextPage,
      id: '_turnNextPage',
      durationTime: Duration(milliseconds: _ehConfigService.turnPageInv),
    );
  }

  Future<void> onLoadCompleted(int ser) async {
    vState.loadCompleMap[ser] = true;

    if (vState.columnMode == ViewColumnMode.single) {
      _startAutoRead();
    } else {
      // 双页阅读
      final int serLeft = vState.columnMode == ViewColumnMode.oddLeft
          ? vState.pageIndex * 2 + 1
          : vState.pageIndex * 2;
      if (vState.filecount > serLeft) {
        final leftComplet = vState.loadCompleMap[serLeft] ?? false;
        final rigthComple = vState.loadCompleMap[serLeft + 1] ?? false;
        logger.v(
            ' $serLeft leftComplet: $leftComplet  , ${serLeft + 1} rigthComple:$rigthComple');
        if (leftComplet && rigthComple) {
          _startAutoRead();
        }
      } else {
        _startAutoRead();
      }
    }
  }

  Future<void> _turnNextPage() async {
    if (vState.autoRead && vState.currentItemIndex < vState.pageCount - 1) {
      logger.v('next page');
      if (pageController.positions.isNotEmpty) {
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
  }

  static Timer? debounceTimer;
  // 防抖函数
  void vDebounce(
    Function? doSomething, {
    required String id,
    Duration durationTime = deFaultDurationTime,
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
}
