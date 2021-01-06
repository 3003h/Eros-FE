import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_view/view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

enum ColumnMode {
  // 双页 奇数页位于左边
  odd,

  // 双页 偶数页位于左边
  even,

  // 单页
  single,
}

class ViewController extends GetxController {
  ViewController(this.initIndex);
  final int initIndex;

  final Rx<ColumnMode> _columnMode = ColumnMode.single.obs;
  ColumnMode get columnMode => _columnMode.value;
  void switchColumnMode() {
    VibrateUtil.light();
    logger.v('switchColumnMode');
    switch (columnMode) {
      case ColumnMode.single:
        logger.d('switchColumnMode itemIndex:$itemIndex to double odd');
        _columnMode.value = ColumnMode.odd;
        pageController.jumpToPage(pageIndex);
        break;
      case ColumnMode.odd:
        logger.d('switchColumnMode itemIndex:$itemIndex to double even');
        _columnMode.value = ColumnMode.even;
        pageController.jumpToPage(pageIndex);
        break;
      case ColumnMode.even:
        logger.d('switchColumnMode itemIndex:$itemIndex to  single');
        _columnMode.value = ColumnMode.single;
        Future.delayed(Duration.zero).then((value) {
          final int _toIndex = pageIndex;
          pageController.jumpToPage(_toIndex);
          logger.d('pageIndex $_toIndex');
          _itemIndex.value = _toIndex;
          sliderValue = _toIndex.toDouble();
        });

        break;
    }
  }

  final RxInt _itemIndex = 0.obs;
  int get itemIndex => _itemIndex.value;
  // set itemIndex(int val) => _itemIndex.value = val;

  int get pageIndex {
    switch (columnMode) {
      case ColumnMode.single:
        return itemIndex;
      case ColumnMode.odd:
        return itemIndex ~/ 2;
      case ColumnMode.even:
        return (itemIndex + 1) ~/ 2;
      default:
        return itemIndex;
    }
  }

  int get pageCount {
    switch (columnMode) {
      case ColumnMode.single:
        return previews.length;
      case ColumnMode.odd:
        return (previews.length / 2).round();
      case ColumnMode.even:
        return (previews.length / 2).round() + 1;
      default:
        return previews.length;
    }
  }

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

  Size screensize;
  double _realPaddingBottom;
  double _realPaddingTop;
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

  final CancelToken _getMoreCancelToken = CancelToken();

  final EhConfigService _ehConfigService = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  GalleryPageController _galleryPageController;

  ViewMode lastViewMode;
  Rx<ViewMode> get _viewMode => _ehConfigService.viewMode;
  ViewMode get viewMode => _viewMode.value;

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
    logger.d('onInit() start');
    _galleryPageController = Get.find(tag: pageCtrlDepth);

    if (GetPlatform.isIOS)
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => SystemChrome.setEnabledSystemUIOverlays([]));

    if (GetPlatform.isIOS)
      ever(_showBar, (bool val) {
        Future.delayed(Duration(milliseconds: 800)).then((value) {
          if (val) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          } else {
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        });
      });

    ever(_itemIndex, (int val) {
      // logger.d('ever _itemIndex to $val');
      Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
        // logger.d('delayed ever _itemIndex to $itemIndex');
        _galleryCacheController.setIndex(
            _galleryPageController.galleryItem.gid, itemIndex,
            notify: false);
      });
    });

    ever(_columnMode, (ColumnMode val) {
      Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
        // logger.d('delayed ever _columnMode to $_columnMode');
        _galleryCacheController.setColumnMode(
            _galleryPageController.galleryItem.gid, val);
      });
    });

    _columnMode.value = _galleryCacheController
            .getGalleryCache(_galleryPageController.galleryItem.gid)
            ?.columnMode ??
        ColumnMode.single;
    // logger.d('init ${_columnMode}');

    logger.d('initIndex $itemIndex');
    _itemIndex.value = initIndex;

    logger.d('initialPage $pageIndex');
    final int _initialPage = pageIndex;
    pageController =
        PageController(initialPage: _initialPage, viewportFraction: 1.1);

    if (viewMode == ViewMode.vertical) {
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => itemScrollController.jumpTo(index: itemIndex));
    }

    final int preload = _ehConfigService.preloadImage.value;
    if (viewMode != ViewMode.vertical) {
      // 预载
      // logger.v('预载后面 $preload 张图 didChangeDependencies');
      GalleryPrecache.instance.precacheImages(
        Get.context,
        _galleryPageController,
        previews: _galleryPageController.previews,
        index: itemIndex,
        max: preload,
      );

      sliderValue = itemIndex / 1.0;
    }

    logger.d('onInit() end');
  }

  @override
  void onClose() {
    pageController.dispose();
    // _getMoreCancelToken.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
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

  void handOnSliderChangedEnd(double value) {
    _itemIndex.value = value.round();
    logger.d('slider to _itemIndex $itemIndex');

    _galleryPageController.showLoadingDialog(Get.context, itemIndex).then((_) {
      if (viewMode != ViewMode.vertical) {
        /*switch (columnMode) {
          case ColumnMode.single:
            pageController.jumpToPage(pageIndex);
            break;
          case ColumnMode.odd:
            pageController.jumpToPage(pageIndex);
            break;
          case ColumnMode.even:
            pageController.jumpToPage(pageIndex);
            break;
        }*/
        pageController.jumpToPage(pageIndex);
      } else {
        Future.delayed(const Duration(milliseconds: 200))
            .then((value) => itemScrollController.jumpTo(index: itemIndex));
      }
    });
  }

  void handOnSliderChanged(double value) {
    sliderValue = value;
  }

  // 页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    logger.d('页码切换时的回调 handOnPageChanged  pageIndex:$pageIndex');
    switch (columnMode) {
      case ColumnMode.single:
        _itemIndex.value = pageIndex;
        break;
      case ColumnMode.odd:
        _itemIndex.value = pageIndex * 2;
        break;
      case ColumnMode.even:
        final int index = pageIndex * 2 - 1;
        _itemIndex.value = index > 0 ? index : 0;
        break;
    }

    logger.d('handOnPageChanged  min');

    GalleryPrecache.instance.precacheImages(
      Get.context,
      _galleryPageController,
      previews: _galleryPageController.previews,
      index: itemIndex,
      max: _ehConfigService.preloadImage.value,
    );
    // logger.d('itemIndex $itemIndex  ${itemIndex.toDouble()}');
    if (itemIndex >= filecount - 1) {
      sliderValue = (filecount - 1).toDouble();
    } else if (itemIndex < 0) {
      sliderValue = 1.0;
    } else {
      sliderValue = itemIndex.toDouble();
    }

    // logger.d('handOnPageChanged  end');
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
    if (index != itemIndex) {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        _itemIndex.value = index;
        sliderValue = itemIndex / 1.0;
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
      if (index != itemIndex) {
        Future.delayed(const Duration(milliseconds: 300)).then((value) {
          _itemIndex.value = index;
          sliderValue = itemIndex / 1.0;
        });
      }
    }
    // logger.i('First Item: ${min ?? ''}\nLast Item: ${max ?? ''}');
  }

  void checkViewModel() {
    logger.d('checkViewModel start');
    if (viewMode != lastViewMode) {
      if (viewMode == ViewMode.vertical) {
        Future.delayed(const Duration(milliseconds: 100)).then((value) {
          itemScrollController.jumpTo(index: itemIndex);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 100)).then((value) {
          pageController.jumpToPage(pageIndex);
        });
      }
      lastViewMode = viewMode;
    }
    logger.d('checkViewModel end');
  }

  void tapLeft() {
    if (viewMode == ViewMode.horizontalLeft) {
      if (pageIndex > 0) {
        pageController.jumpToPage(pageIndex - 1);
      }
    } else if (viewMode == ViewMode.horizontalRight) {
      pageController.jumpToPage(pageIndex + 1);
    }
  }

  void tapRight() {
    if (viewMode == ViewMode.horizontalLeft) {
      pageController.jumpToPage(pageIndex + 1);
    } else if (viewMode == ViewMode.horizontalRight) {
      if (pageIndex > 0) {
        pageController.jumpToPage(pageIndex - 1);
      }
    }
  }
}
