import 'dart:async';

import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart' as utility;
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:fehviewer/generated/l10n.dart';

import 'view_state.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

class ViewController extends GetxController {
  ViewController();

  // 状态
  final ViewState vState = ViewState();

  /// 切换单页双页模式
  void switchColumnMode() {
    vibrateUtil.light();
    logger.v('切换单页双页模式');
    switch (vState.columnMode) {
      case ViewColumnMode.single:
        logger.d('单页 => 双页1. itemIndex:${vState.itemIndex},');
        vState.columnMode = ViewColumnMode.odd;
        pageController.jumpToPage(vState.pageIndex);
        break;
      case ViewColumnMode.odd:
        logger.d('双页1 => 双页2, itemIndex:${vState.itemIndex}');
        vState.columnMode = ViewColumnMode.even;
        vState.needRebuild = true;
        pageController.jumpToPage(vState.pageIndex);
        break;
      case ViewColumnMode.even:
        logger.d('双页2 => 单页, itemIndex:${vState.itemIndex}');
        vState.columnMode = ViewColumnMode.single;
        Future.delayed(Duration.zero).then((_) {
          final int _toIndex = vState.pageIndex;
          pageController.jumpToPage(_toIndex);
          logger.d('pageIndex $_toIndex');
          vState.itemIndex = _toIndex;
          vState.sliderValue = _toIndex.toDouble();
        });

        break;
    }
  }

  late PageController pageController;
  late PageController _pageControllerNotInv;
  late PageController _pageControllerInv;

  final EhConfigService _ehConfigService = Get.find();
  final GalleryPageController _galleryPageController =
      Get.find(tag: pageCtrlDepth);

  late int lastImagesSize;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late DeviceOrientation _deviceOrientation;
  late StreamSubscription<DeviceOrientation> subscription;

  @override
  void onInit() {
    super.onInit();
    // logger.d('ViewController onInit() start');

    // if (GetPlatform.isIOS)
    //   Future.delayed(const Duration(milliseconds: 200))
    //       .then((_) => SystemChrome.setEnabledSystemUIOverlays([]));

    if (GetPlatform.isIOS)
      Future.delayed(const Duration(milliseconds: 200))
          .then((_) => FlutterStatusbarManager.setFullscreen(true));

    // logger.d('初始化page页码 ${vState.pageIndex}');
    final int _initialPage = vState.pageIndex;

    // 横屏模式pageview控制器初始化
    pageController =
        PageController(initialPage: _initialPage, viewportFraction: 1.0);

    // 竖屏模式初始页码
    if (vState.viewMode == ViewMode.topToBottom) {
      // logger.v('竖屏模式初始页码: ${vState.itemIndex}');
      Future.delayed(const Duration(milliseconds: 200)).then(
          (value) => itemScrollController.jumpTo(index: vState.itemIndex));
    }

    /// 初始预载
    /// 后续的预载触发放在翻页事件中
    final int _preload = _ehConfigService.preloadImage.value;
    if (vState.viewMode != ViewMode.topToBottom) {
      // 预载
      // logger.v('初始预载');
      GalleryPara.instance
          .precacheImages(
        Get.context!,
        imageMap: vState.imageMap,
        itemSer: vState.itemIndex,
        max: _preload,
      )
          .listen((GalleryImage? event) {
        if (event != null) {
          // logger5.d('preloadImage upt previewMap ${event.ser}');
          _galleryPageController.uptImageBySer(ser: event.ser, image: event);
        }
      });
    }

    vState.sliderValue = vState.itemIndex / 1.0;

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

  /// SliderChangedEnd
  Future<void> handOnSliderChangedEnd(double value) async {
    vState.conditionItemIndex = false;
    vState.itemIndex = value.round();
    logger.d('slider to _itemIndex ${vState.itemIndex}');

    if (vState.viewMode != ViewMode.topToBottom) {
      pageController.jumpToPage(vState.pageIndex);
    } else {
      itemScrollController.jumpTo(index: vState.itemIndex);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    update([GetIds.IMAGE_VIEW_SLIDER]);
    vState.conditionItemIndex = true;
  }

  void handOnSliderChanged(double value) {
    vState.sliderValue = value;
    update([GetIds.IMAGE_VIEW_SLIDER]);
  }

  // 页码切换时的回调
  void handOnPageChanged(int pageIndex) {
    // 根据columnMode的不同设置不同的itemIndex值
    switch (vState.columnMode) {
      case ViewColumnMode.single:
        vState.itemIndex = pageIndex;
        break;
      case ViewColumnMode.odd:
        vState.itemIndex = pageIndex * 2;
        break;
      case ViewColumnMode.even:
        final int index = pageIndex * 2 - 1;
        vState.itemIndex = index > 0 ? index : 0;
        break;
    }

    // logger.d(
    //     '页码切换时的回调 handOnPageChanged  pageIndex:$pageIndex itemIndex${vState.itemIndex}');

    // 预载图片
    // logger.v('页码切换时的回调 预载图片');
    GalleryPara.instance
        .precacheImages(
      Get.context!,
      imageMap: _galleryPageController.imageMap,
      itemSer: vState.itemIndex,
      max: _ehConfigService.preloadImage.value,
    )
        .listen((GalleryImage? event) {
      if (event != null) {
        _galleryPageController.uptImageBySer(ser: event.ser, image: event);
      }
    });
    // logger.d('itemIndex $itemIndex  ${itemIndex.toDouble()}');
    if (vState.itemIndex >= vState.filecount - 1) {
      vState.sliderValue = (vState.filecount - 1).toDouble();
    } else if (vState.itemIndex < 0) {
      vState.sliderValue = 1.0;
    } else {
      vState.sliderValue = vState.itemIndex.toDouble();
    }

    // logger.d('handOnPageChanged  end');
  }

  // 点击中间
  Future<void> handOnTapCent() async {
    if (GetPlatform.isIOS) {
      // 会rebuild GalleryViewPage
      if (!vState.showBar) {
        // await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        // await FlutterStatusbarManager.setHidden(false,
        //     animation: StatusBarAnimation.SLIDE);
        await FlutterStatusbarManager.setFullscreen(false);
        vState.showBar = !vState.showBar;
      } else {
        vState.showBar = !vState.showBar;
        await Future.delayed(Duration(milliseconds: 200));
        // SystemChrome.setEnabledSystemUIOverlays([]);
        // await FlutterStatusbarManager.setHidden(true,
        //     animation: StatusBarAnimation.SLIDE);
        await FlutterStatusbarManager.setFullscreen(true);
      }
    } else {
      vState.showBar = !vState.showBar;
    }
  }

  // 点击周围
  void handOnPanDown(DragDownDetails details) {
    final Rect _centRect =
        utility.WidgetUtil.getWidgetGlobalRect(vState.centkey);

    final double _dx = details.globalPosition.dx;
    final double _dy = details.globalPosition.dy;
    // logger.d(
    //     'onPanDown ${details.globalPosition}  $_centRect');
    if ((_dx < _centRect.left || _dx > _centRect.right) &&
        (_dy < _centRect.top || _dy > _centRect.bottom)) {
      logger.d('onPanDown hide bar');
      vState.showBar = false;
    }
  }

  void onDidFinishLayout(int firstIndex, int lastIndex) {
    // logger.d('firstIndex: $firstIndex, lastIndex: $lastIndex');
    final int index = (lastIndex + firstIndex) ~/ 2;
    // logger.d('$index ');
    if (index != vState.itemIndex) {
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        vState.itemIndex = index;
        vState.sliderValue = vState.itemIndex / 1.0;
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

      vState.tempIndex = (min + max) ~/ 2;
      // logger.v('max $max  min $min tempIndex ${vState.tempIndex}');

      // logger.d('${positions.elementAt(index).itemLeadingEdge} ');
      if (vState.tempIndex != vState.itemIndex && vState.conditionItemIndex) {
        Future.delayed(const Duration(milliseconds: 300)).then((value) {
          logger.v('tempIndex ${vState.tempIndex}');
          vState.itemIndex = vState.tempIndex;
          vState.sliderValue = vState.itemIndex / 1.0;
          update([GetIds.IMAGE_VIEW_SLIDER]);
        });
      }
    }
    // logger.i('First Item: ${min ?? ''}\nLast Item: ${max ?? ''}');
  }

  /// 检查模式 及处理
  void checkViewModel() {
    // logger.d('checkViewModel start');
    if (vState.viewMode != vState.lastViewMode) {
      if (vState.viewMode == ViewMode.topToBottom) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          itemScrollController.jumpTo(index: vState.itemIndex);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          pageController.jumpToPage(vState.pageIndex);
        });
      }
      vState.lastViewMode = vState.viewMode;
    }
    // logger.d('checkViewModel end');
  }

  // 点击左半边
  void tapLeft() {
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight) {
      if (vState.pageIndex > 0) {
        pageController.jumpToPage(vState.pageIndex - 1);
      }
    } else if (vState.viewMode == ViewMode.rightToLeft) {
      pageController.jumpToPage(vState.pageIndex + 1);
    }
  }

  // 点击右半边
  void tapRight() {
    vState.fade = false;
    if (vState.viewMode == ViewMode.LeftToRight) {
      pageController.jumpToPage(vState.pageIndex + 1);
    } else if (vState.viewMode == ViewMode.rightToLeft) {
      if (vState.pageIndex > 0) {
        pageController.jumpToPage(vState.pageIndex - 1);
      }
    }
  }

  // 点击自动阅读
  Future<void> tapAutoRead(BuildContext context) async {
    logger.d('tap autoRead');

    if (!vState.autoRead) {
      await _setAutoReadInv(context);
    } else {
      vState.autoRead = !vState.autoRead;
    }

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
    final int? inv = await _showAutoReadInvPicker(context, EHConst.invList,
        initIndex: initIndex);

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
  }

  void _startAutoRead() {
    debounce(
        _turnNextPage, Duration(milliseconds: _ehConfigService.turnPageInv));
  }

  Future<void> _turnNextPage() async {
    if (vState.autoRead && vState.pageIndex < vState.pageCount - 1) {
      logger.v('next page');
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> onLoadCompleted(int ser) async {
    vState.loadCompleMap[ser] = true;

    if (vState.columnMode == ViewColumnMode.single) {
      _startAutoRead();
    } else {
      // 双页阅读
      final int serLeft = vState.columnMode == ViewColumnMode.odd
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

  static const deFaultDurationTime = Duration(milliseconds: 300);
  static Timer? timer;

  // 防抖函数
  void debounce(Function? doSomething,
      [Duration durationTime = deFaultDurationTime]) {
    // timer?.cancel();
    if (timer?.isActive ?? false) {
      logger.v('timer.cancel');
      timer?.cancel();
    }
    timer = Timer(durationTime, () {
      loggerTime.v('func.call');
      doSomething?.call();
      timer = null;
    });
  }

  /// 函数防抖
  ///
  /// [func]: 要执行的方法
  /// [delay]: 要迟延的时长
  Function _debounce(
    Function? func, [
    Duration delay = const Duration(milliseconds: 2000),
  ]) {
    logger.d('debounce');
    Timer? timer;
    final Function target = () {
      if (timer?.isActive ?? false) {
        logger.d('timer.cancel');
        timer?.cancel();
      }
      timer = Timer(delay, () async {
        loggerTime.d('func.call');
        await func?.call();
      });
    };
    return target;
  }
}
