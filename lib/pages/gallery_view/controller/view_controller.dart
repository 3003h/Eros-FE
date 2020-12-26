import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_view/view/gallery_view_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

class ViewController extends GetxController {
  ViewController(this.index);

  // final String gid;

  final int index;

  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  set currentIndex(int val) => _currentIndex.value = val;

  final RxDouble _sliderValue = 0.0.obs;

  double get sliderValue => _sliderValue.value;

  set sliderValue(double val) => _sliderValue.value = val;

  final RxBool _showBar = false.obs;

  bool get showBar => _showBar.value;

  set showBar(bool val) => _showBar.value = val;

  // 底栏显示隐藏切换
  double get bottomBarOffset {
    // 底栏底部距离
    realPaddingBottom = Platform.isAndroid ? 20 + paddingBottom : paddingBottom;

    // 底栏隐藏时偏移
    final double _offsetBottomHide = realPaddingBottom + kBottomBarHeight * 2;
    if (showBar) {
      return 0;
    } else {
      return -_offsetBottomHide - 10;
    }
  }

  // 顶栏隐藏时偏移
  double get topBarOffset {
    final double _offsetTopHide = kTopBarHeight + paddingTop;
    if (showBar) {
      return 0;
    } else {
      return -_offsetTopHide - 10;
    }
  }

  double realPaddingBottom;
  double bottomBarWidth;

  double realPaddingTop;
  double topBarWidth;

  Size screensize;
  double paddingLeft;
  double paddingRight;
  double paddingTop;
  double paddingBottom;

  final GlobalKey centkey = GlobalKey();

  PageController pageController;

  Future<GalleryPreview> futureViewGallery;

  final CancelToken _getMoreCancelToken = CancelToken();

  final EhConfigService _ehConfigService = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  GalleryPageController _galleryPageController;

  ViewMode get viewMode => _ehConfigService.viewMode.value;

  List<GalleryPreview> get previews => _galleryPageController.previews;

  // String get filecount => _galleryPageController.galleryItem.filecount;
  int get filecount =>
      int.parse(_galleryPageController.galleryItem.filecount ?? '0');

  @override
  void onInit() {
    super.onInit();
    _galleryPageController =
        Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');

    currentIndex = 0;
    showBar = false;
    logger.d('_index $index');
    pageController = PageController(initialPage: index, viewportFraction: 1.1);

    final int preload = _ehConfigService.preloadImage.value;
    if (_ehConfigService.viewMode.value != ViewMode.vertical) {
      // 预载后面5张图
      logger.v('预载后面 $preload 张图 didChangeDependencies');
      GalleryPrecache.instance.precacheImages(
        Get.context,
        _galleryPageController,
        previews: _galleryPageController.previews,
        index: index,
        max: preload,
      );

      currentIndex = index;
      Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
        _galleryCacheController.setIndex(
            _galleryPageController.galleryItem.gid, currentIndex,
            notify: false);
      });
      sliderValue = currentIndex / 1.0;
      futureViewGallery = _getImageInfo();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    _getMoreCancelToken.cancel();
    super.onClose();
  }

  void initSize(BuildContext context) {
    final MediaQueryData _mq = MediaQuery.of(context);
    screensize = _mq.size;
    paddingLeft = _mq.padding.left;
    paddingRight = _mq.padding.right;
    paddingTop = _mq.padding.top;
    paddingBottom = _mq.padding.bottom;
    realPaddingTop = paddingTop;
  }

  Future<GalleryPreview> _getImageInfo() async {
    return _galleryPageController.getImageInfo(currentIndex,
        cancelToken: _getMoreCancelToken);
  }

  void handOnSliderChangedEnd(double value) {
    logger.d('to $value');
    final int _index = value ~/ 1;
    _galleryPageController.showLoadingDialog(Get.context, _index).then((_) {
      _galleryCacheController.setIndex(
          _galleryPageController.galleryItem.gid, _index);
      pageController.jumpToPage(_index);
    });
  }

  void handOnSliderChanged(double value) {
    sliderValue = value;
  }

  // 页码切换的回调
  void handOnPageChanged(int index) {
    GalleryPrecache.instance.precacheImages(
      Get.context,
      _galleryPageController,
      previews: _galleryPageController.previews,
      index: index,
      max: _ehConfigService.preloadImage.value,
    );
    currentIndex = index;
    sliderValue = currentIndex / 1.0;
    _galleryCacheController.setIndex(
        _galleryPageController.galleryItem.gid, currentIndex);
  }

  // 点击中间
  void handOnTapCent() {
    showBar = !showBar;
  }

  // 点击周围
  void handOnPanDown(DragDownDetails details) {
    final Rect _centRect = WidgetUtil.getWidgetGlobalRect(centkey);

    final double _dx = details.globalPosition.dx;
    final double _dy = details.globalPosition.dy;
    // logger.d(
    //     'onPanDown ${details.globalPosition}  $_centRect');
    if ((_dx < _centRect.left || _dx > _centRect.right) &&
        (_dy < _centRect.top || _dy > _centRect.bottom)) {
      logger.d('onPanDown hide bar');
      showBar = false;
    }
  }
}
