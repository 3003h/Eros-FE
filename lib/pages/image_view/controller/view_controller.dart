import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'view_state.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

class ViewController extends GetxController {
  ViewController();

  // 状态
  final ViewState state = ViewState();

  /// 切换单页双页模式
  void switchColumnMode() {
    VibrateUtil.light();
    logger.v('switchColumnMode');
    switch (state.columnMode) {
      case ColumnMode.single:
        logger.d('switchColumnMode itemIndex:${state.itemIndex} to double odd');
        state.columnMode = ColumnMode.odd;
        pageController.jumpToPage(state.pageIndex);
        break;
      case ColumnMode.odd:
        logger
            .d('switchColumnMode itemIndex:${state.itemIndex} to double even');
        state.columnMode = ColumnMode.even;
        pageController.jumpToPage(state.pageIndex);
        break;
      case ColumnMode.even:
        logger.d('switchColumnMode itemIndex:${state.itemIndex} to  single');
        state.columnMode = ColumnMode.single;
        Future.delayed(Duration.zero).then((_) {
          final int _toIndex = state.pageIndex;
          pageController.jumpToPage(_toIndex);
          logger.d('pageIndex $_toIndex');
          state.itemIndex = _toIndex;
          state.sliderValue = _toIndex.toDouble();
        });

        break;
    }
  }

  PageController pageController;

  final EhConfigService _ehConfigService = Get.find();
  final GalleryPageController _galleryPageController =
      Get.find(tag: pageCtrlDepth);

  int lastPreviewLen;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void onInit() {
    super.onInit();
    logger.d('ViewController onInit() start');

    if (GetPlatform.isIOS)
      Future.delayed(const Duration(milliseconds: 200))
          .then((_) => SystemChrome.setEnabledSystemUIOverlays([]));

    logger.d('初始化page页码 ${state.pageIndex}');
    final int _initialPage = state.pageIndex;

    // 横屏模式pageview控制器初始化
    pageController =
        PageController(initialPage: _initialPage, viewportFraction: 1.1);

    // 竖屏模式初始页码
    if (state.viewMode == ViewMode.vertical) {
      loggerNoStack.v('竖屏模式初始页码: ${state.itemIndex}');
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => itemScrollController.jumpTo(index: state.itemIndex));
    }

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    final int _preload = _ehConfigService.preloadImage.value;
    if (state.viewMode != ViewMode.vertical) {
      // 预载
      GalleryPara.instance.precacheImages(
        Get.context,
        previews: state.previews,
        index: state.itemIndex,
        max: _preload,
      );
    }

    state.sliderValue = state.itemIndex / 1.0;

    logger.d('onInit() end');
  }

  @override
  void onClose() {
    pageController.dispose();
    state.getMoreCancelToken.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.onClose();
  }

  void handOnSliderChangedEnd(double value) {
    state.itemIndex = value.round();
    logger.d('slider to _itemIndex ${state.itemIndex}');

    _galleryPageController
        .showLoadingDialog(Get.context, state.itemIndex)
        .then((_) {
      if (state.viewMode != ViewMode.vertical) {
        pageController.jumpToPage(state.pageIndex);
      } else {
        Future.delayed(const Duration(milliseconds: 200)).then(
            (value) => itemScrollController.jumpTo(index: state.itemIndex));
      }
    });
  }

  void handOnSliderChanged(double value) {
    state.sliderValue = value;
  }

  // 页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    // 根据columnMode的不同设置不同的itemIndex值
    switch (state.columnMode) {
      case ColumnMode.single:
        state.itemIndex = pageIndex;
        break;
      case ColumnMode.odd:
        state.itemIndex = pageIndex * 2;
        break;
      case ColumnMode.even:
        final int index = pageIndex * 2 - 1;
        state.itemIndex = index > 0 ? index : 0;
        break;
    }

    logger.d(
        '页码切换时的回调 handOnPageChanged  pageIndex:$pageIndex itemIndex${state.itemIndex}');

    // 预载图片
    GalleryPara.instance.precacheImages(
      Get.context,
      previews: _galleryPageController.previews,
      index: state.itemIndex,
      max: _ehConfigService.preloadImage.value,
    );
    // logger.d('itemIndex $itemIndex  ${itemIndex.toDouble()}');
    if (state.itemIndex >= state.filecount - 1) {
      state.sliderValue = (state.filecount - 1).toDouble();
    } else if (state.itemIndex < 0) {
      state.sliderValue = 1.0;
    } else {
      state.sliderValue = state.itemIndex.toDouble();
    }

    // logger.d('handOnPageChanged  end');
  }

  // 点击中间
  Future<void> handOnTapCent() async {
    if (GetPlatform.isIOS) {
      // 会rebuild GalleryViewPage
      if (!state.showBar) {
        await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        state.showBar = !state.showBar;
      } else {
        state.showBar = !state.showBar;
        await Future.delayed(Duration(milliseconds: 200));
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
    } else {
      state.showBar = !state.showBar;
    }
  }

  // 点击周围
  void handOnPanDown(DragDownDetails details) {
    final Rect _centRect = WidgetUtil.getWidgetGlobalRect(state.centkey);

    final double _dx = details.globalPosition.dx;
    final double _dy = details.globalPosition.dy;
    // logger.d(
    //     'onPanDown ${details.globalPosition}  $_centRect');
    if ((_dx < _centRect.left || _dx > _centRect.right) &&
        (_dy < _centRect.top || _dy > _centRect.bottom)) {
      logger.d('onPanDown hide bar');
      state.showBar = false;
    }
  }

  void onDidFinishLayout(int firstIndex, int lastIndex) {
    // logger.d('firstIndex: $firstIndex, lastIndex: $lastIndex');
    final int index = (lastIndex + firstIndex) ~/ 2;
    // logger.d('$index ');
    if (index != state.itemIndex) {
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        state.itemIndex = index;
        state.sliderValue = state.itemIndex / 1.0;
      });
    }
    // currentIndex = index;
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

      final int index = (min + max) ~/ 2;

      // logger.d('${positions.elementAt(index).itemLeadingEdge} ');
      if (index != state.itemIndex) {
        Future.delayed(const Duration(milliseconds: 300)).then((value) {
          state.itemIndex = index;
          state.sliderValue = state.itemIndex / 1.0;
        });
      }
    }
    // logger.i('First Item: ${min ?? ''}\nLast Item: ${max ?? ''}');
  }

  /// 检查模式 及处理
  void checkViewModel() {
    // logger.d('checkViewModel start');
    if (state.viewMode != state.lastViewMode) {
      if (state.viewMode == ViewMode.vertical) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          itemScrollController.jumpTo(index: state.itemIndex);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          pageController.jumpToPage(state.pageIndex);
        });
      }
      state.lastViewMode = state.viewMode;
    }
    // logger.d('checkViewModel end');
  }

  // 点击左半边
  void tapLeft() {
    if (state.viewMode == ViewMode.horizontalLeft) {
      if (state.pageIndex > 0) {
        pageController.jumpToPage(state.pageIndex - 1);
      }
    } else if (state.viewMode == ViewMode.horizontalRight) {
      pageController.jumpToPage(state.pageIndex + 1);
    }
  }

  // 点击右半边
  void tapRight() {
    if (state.viewMode == ViewMode.horizontalLeft) {
      pageController.jumpToPage(state.pageIndex + 1);
    } else if (state.viewMode == ViewMode.horizontalRight) {
      if (state.pageIndex > 0) {
        pageController.jumpToPage(state.pageIndex - 1);
      }
    }
  }
}
