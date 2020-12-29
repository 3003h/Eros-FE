import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_view/view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
    _realPaddingBottom =
        Platform.isAndroid ? 20 + _paddingBottom : _paddingBottom;

    // 底栏隐藏时偏移
    final double _offsetBottomHide = _realPaddingBottom + kBottomBarHeight * 2;
    if (showBar) {
      return 0;
    } else {
      return -_offsetBottomHide - 10;
    }
  }

  // 顶栏隐藏时偏移
  double get topBarOffset {
    final double _offsetTopHide = kTopBarHeight + _paddingTop;
    if (showBar) {
      return 0;
    } else {
      return -_offsetTopHide - 10;
    }
  }

  double _realPaddingBottom;

  double _realPaddingTop;

  Size screensize;
  double _paddingLeft;
  double _paddingRight;
  double _paddingTop;
  double _paddingBottom;

  EdgeInsets get topBarPadding => EdgeInsets.fromLTRB(
        _paddingLeft,
        _realPaddingTop,
        _paddingRight,
        4.0,
      );

  EdgeInsets get bottomBarPadding => EdgeInsets.only(
        bottom: _realPaddingBottom,
        left: _paddingLeft,
        right: _paddingRight,
      );

  final GlobalKey centkey = GlobalKey();

  PageController pageController;

  // Future<GalleryPreview> futureViewGallery;

  final CancelToken _getMoreCancelToken = CancelToken();
  final EhConfigService _ehConfigService = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  GalleryPageController _galleryPageController;

  Rx<ViewMode> get _viewMode => _ehConfigService.viewMode;
  ViewMode get viewMode => _viewMode.value;

  ViewMode lastViewMode;

  List<GalleryPreview> get previews => _galleryPageController.previews;

  int lastPreviewLen;

  int get filecount =>
      int.parse(_galleryPageController.galleryItem.filecount ?? '0');

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void onInit() {
    super.onInit();
    _galleryPageController =
        Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');

    currentIndex = 0;
    showBar = false;
    logger.d('_index $index');
    pageController = PageController(initialPage: index, viewportFraction: 1.1);

    Future.delayed(const Duration(milliseconds: 200))
        .then((value) => itemScrollController.jumpTo(index: index));

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
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    // _getMoreCancelToken.cancel();
    super.onClose();
  }

  void initSize(BuildContext context) {
    final MediaQueryData _mq = MediaQuery.of(context);
    screensize = _mq.size;
    _paddingLeft = _mq.padding.left;
    _paddingRight = _mq.padding.right;
    _paddingTop = _mq.padding.top;
    _paddingBottom = _mq.padding.bottom;
    _realPaddingTop = _paddingTop;
  }

  /*Future<GalleryPreview> getImageInfo() async {
    return _galleryPageController.getImageInfo(currentIndex,
        cancelToken: _getMoreCancelToken);
  }*/

  void handOnSliderChangedEnd(double value) {
    final int _index = value.round();
    logger.d('to index $_index');

    _galleryPageController.showLoadingDialog(Get.context, _index).then((_) {
      _galleryCacheController.setIndex(
          _galleryPageController.galleryItem.gid, _index);
      if (viewMode != ViewMode.vertical) {
        pageController.jumpToPage(_index);
      } else {
        // sliderValue = currentIndex / 1.0;
        Future.delayed(const Duration(milliseconds: 200))
            .then((value) => itemScrollController.jumpTo(index: _index));
      }
    });
  }

  void handOnSliderChanged(double value) {
    sliderValue = value;
  }

  // 页码切换时的回调
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

    logger.d('${lastPreviewLen - index}');
    // update(['_buildPhotoViewGallery'], lastPreviewLen - index < 4);
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

  void onDidFinishLayout(int firstIndex, int lastIndex) {
    // logger.d('firstIndex: $firstIndex, lastIndex: $lastIndex');
    final int index = (lastIndex + firstIndex) ~/ 2;
    // logger.d('$index ');
    if (index != currentIndex) {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        currentIndex = index;
        sliderValue = currentIndex / 1.0;
        _galleryCacheController.setIndex(
            _galleryPageController.galleryItem.gid, currentIndex);
      });
    }
    // currentIndex = index;
  }

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

      final int index = (min + max) ~/ 2;

      // logger.d('${positions.elementAt(index).itemLeadingEdge} ');
      if (index != currentIndex) {
        Future.delayed(const Duration(milliseconds: 300)).then((value) {
          currentIndex = index;
          sliderValue = currentIndex / 1.0;
          _galleryCacheController.setIndex(
              _galleryPageController.galleryItem.gid, currentIndex);
        });
      }
    }
    // logger.i('First Item: ${min ?? ''}\nLast Item: ${max ?? ''}');
  }

  void checkViewModel() {
    if (viewMode != lastViewMode) {
      if (viewMode == ViewMode.vertical) {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          itemScrollController.jumpTo(index: currentIndex);
        });
      } else {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          pageController.jumpToPage(currentIndex);
        });
      }
      lastViewMode = viewMode;
    }
  }
}
