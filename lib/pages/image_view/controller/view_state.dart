import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'view_controller.dart';

enum ColumnMode {
  // 双页 奇数页位于左边
  odd,

  // 双页 偶数页位于左边
  even,

  // 单页
  single,
}

class ViewState {
  ViewState() {
    // 初始化 设置Rx变量的ever事件
    logger.v('初始化ViewState');

    ever(_itemIndex, (int val) {
      logger.d('ever _itemIndex to $val');
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

    final _iniIndex = Get.arguments as int;
    itemIndex = _iniIndex;
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

  final EhConfigService _ehConfigService = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  final GalleryPageController _galleryPageController =
      Get.find(tag: pageCtrlDepth);

  final GlobalKey centkey = GlobalKey();
  final CancelToken getMoreCancelToken = CancelToken();

  List<GalleryPreview> get previews => _galleryPageController.previews;
  int get filecount =>
      int.parse(_galleryPageController.galleryItem.filecount ?? '0');

  /// 横屏翻页模式
  final Rx<ColumnMode> _columnMode = ColumnMode.single.obs;
  ColumnMode get columnMode => _columnMode.value;
  set columnMode(val) => _columnMode.value = val;

  /// 当前查看的图片inde
  final RxInt _itemIndex = 0.obs;
  int get itemIndex => _itemIndex.value;
  set itemIndex(int val) {
    logger.d('set itemIndex to $val');
    _itemIndex.value = val;
  }

  /// pageview下实际的index
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

  /// pageview下实际能翻页的总数
  int get pageCount {
    switch (columnMode) {
      case ColumnMode.single:
        return previews.length;
      case ColumnMode.odd:
        return (previews.length / 2).round();
      case ColumnMode.even:
        return (previews.length / 2).round() + ((previews.length + 1) % 2);
      default:
        return previews.length;
    }
  }

  /// 滑条的值
  final RxDouble _sliderValue = 0.0.obs;
  double get sliderValue => _sliderValue.value;
  set sliderValue(double val) => _sliderValue.value = val;

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

  /// 是否显示bar
  final RxBool _showBar = false.obs;
  bool get showBar => _showBar.value;
  set showBar(bool val) => _showBar.value = val;

  // 底栏偏移
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

  // 顶栏偏移
  double get topBarOffset {
    final double _offsetTopHide = kTopBarHeight + _paddingTop;
    if (showBar) {
      return 0;
    } else {
      return -_offsetTopHide - 10;
    }
  }

  ViewMode lastViewMode;

  /// 阅读模式
  Rx<ViewMode> get _viewMode => _ehConfigService.viewMode;
  ViewMode get viewMode => _viewMode.value;
  set viewMode(val) => _viewMode.value = val;

  bool fade = true;
}
