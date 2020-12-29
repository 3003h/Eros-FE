import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

class GalleryItemController extends GetxController {
  GalleryItemController.initData(GalleryItem galleryItem,
      {@required String tabIndex}) {
    // ignore: prefer_initializing_formals
    this.galleryItem = galleryItem;
    _tabindex = tabIndex;
  }

  final EhConfigService _ehConfigService = Get.find();

  void onTap() {
    logger.d('${galleryItem.englishTitle}');
    NavigatorUtil.goGalleryPage(galleryItem: galleryItem, tabIndex: _tabindex);
  }

  void onTapDown(_) => _updatePressedColor();
  void onTapUp(_) {
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      _updateNormalColor();
    });
  }

  void onTapCancel() => _updateNormalColor();

  @override
  void onInit() {
    super.onInit();
    if (galleryItem.favTitle != null && galleryItem.favTitle.isNotEmpty) {
      isFav = true;
    }
  }

  final RxBool _isFav = false.obs;
  bool get isFav => _isFav.value;
  set isFav(bool val) => _isFav.value = val;

  void setFavTitle(String favTitle, {String favcat}) {
    galleryItem.favTitle = favTitle;
    isFav = favTitle.isNotEmpty;
    if (favcat != null) {
      galleryItem.favcat = favcat;
      logger.d('item show fav');
    } else {
      galleryItem.favcat = '';
      galleryItem.favTitle = '';
    }
  }

  String get title {
    if (_ehConfigService.isJpnTitle.value &&
        galleryItem.japaneseTitle.isNotEmpty) {
      return galleryItem.japaneseTitle;
    } else {
      return galleryItem.englishTitle;
    }
  }

  String _tabindex;
  List<GalleryPreview> firstPagePreview;
  GalleryItem galleryItem;

  Rx<Color> colorTap = const Color.fromARGB(0, 0, 0, 0).obs;

  void _updateNormalColor() {
    colorTap.value = null;
  }

  void _updatePressedColor() {
    colorTap.value =
        CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, Get.context);
  }

  set localFav(bool value) {
    galleryItem.localFav = value;
    update();
  }

  bool get localFav => galleryItem.localFav;

  void firstPutPreview(List<GalleryPreview> galleryPreview) {
    if (galleryPreview.isNotEmpty) {
      galleryItem.galleryPreview = galleryPreview;
    }

    firstPagePreview =
        galleryItem.galleryPreview.sublist(0, galleryPreview.length);
    // logger.d(' _firstPagePreview ${firstPagePreview.length}');
  }
}
