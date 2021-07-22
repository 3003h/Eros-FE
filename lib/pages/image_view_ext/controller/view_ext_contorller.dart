import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:get/get.dart';

import 'view_ext_state.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 44.0;

const String idViewTopBar = 'ViewExtController.ViewTopBar';
const String idViewBottomBar = 'ViewExtController.ViewBottomBar';
const String idViewBar = 'ViewExtController.ViewBar';
const String idViewPageSlider = 'ViewExtControlle˙r.ViewPageSlider';

/// 支持在线以及本地（已下载）阅读的组件
class ViewExtController extends GetxController {
  /// 状态
  final ViewExtState vState = ViewExtState();

  late PageController pageController;

  GalleryPageController get _galleryPageController =>
      vState.galleryPageController;
  EhConfigService get _ehConfigService => vState.ehConfigService;

  late Future<GalleryImage?> imageFuture;

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
    vState.currentItemIndex = pageIndex;

    if (vState.currentItemIndex >= vState.filecount - 1) {
      vState.sliderValue = (vState.filecount - 1).toDouble();
    } else if (vState.currentItemIndex < 0) {
      vState.sliderValue = 1.0;
    } else {
      vState.sliderValue = vState.currentItemIndex.toDouble();
    }
    update([idViewTopBar, idViewPageSlider]);
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
    imageFuture = fetchImage(
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
    // TODO(honjow): 双页 以及上下滚动模式
    pageController.jumpToPage(vState.currentItemIndex);
  }

  void handOnSliderChanged(double value) {
    vState.sliderValue = value;
    update([idViewPageSlider]);
  }
}
