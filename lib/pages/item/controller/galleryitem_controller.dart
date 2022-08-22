import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/controller/fav_controller.dart';
import 'package:fehviewer/pages/item/item_base.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryItemController extends GetxController {
  GalleryItemController({required this.galleryProvider});

  final EhConfigService _ehConfigService = Get.find();
  final FavController _favDialogController = Get.find();
  final TabHomeController _tabHomeController = Get.find();
  final HistoryController _historyController = Get.find();

  late List<GalleryImage> firstPageImage;
  final GalleryProvider galleryProvider;

  final RxBool _isFav = false.obs;
  bool get isFav => _isFav.value;
  set isFav(bool val) => _isFav.value = val;

  final _favCat = ''.obs;
  String get favCat => _favCat.value;
  set favCat(String val) => _favCat.value = val;

  final _rating = 0.0.obs;
  double get rating => _rating.value;
  set rating(double val) => _rating.value = val;

  final _ratingFallBack = 0.0.obs;
  double get ratingFallBack => _ratingFallBack.value;
  set ratingFallBack(double val) => _ratingFallBack.value = val;

  final _colorRating = ''.obs;
  String get colorRating => _colorRating.value;
  set colorRating(String val) => _colorRating.value = val;

  @override
  void onInit() {
    super.onInit();
    logger.v(
        'init GalleryProviderController ${galleryProvider.gid}  ${galleryProvider.englishTitle}');
    if (galleryProvider.favTitle != null &&
        galleryProvider.favTitle!.isNotEmpty) {
      isFav = true;
    }

    rating = galleryProvider.rating ?? 0.00;
    colorRating = galleryProvider.colorRating ?? '';

    ratingFallBack = galleryProvider.ratingFallBack ?? 0.00;
    logger.v('ratingFB=$ratingFallBack');

    favCat = galleryProvider.favcat ?? '';
    logger.v('favCat=$favCat');
  }

  int get tagLine => max(
          1,
          (getLimitSimpleTags(galleryProvider.simpleTags,
                          _ehConfigService.listViewTagLimit)
                      ?.length ??
                  0) /
              4)
      .round();

  /// 设置收藏夹
  void setFavTitleAndFavcat({String favTitle = '', String? favcat}) {
    logger.v('设置收藏夹, 原 isFav :[$isFav]');
    galleryProvider.copyWith(favTitle: favTitle);
    isFav = favTitle.isNotEmpty;
    logger.v('设置收藏夹, 当前 isFav :[$isFav]');
    if (favcat != null || (favcat?.isNotEmpty ?? false)) {
      favCat = favcat!;
      galleryProvider.copyWith(favcat: favcat);
      logger.v('item set favcat [$favcat]');
    } else {
      favCat = '';
      galleryProvider.copyWith(favcat: '', favTitle: '');
    }
  }

  String get title {
    if ((_ehConfigService.isJpnTitle.value) &&
        (galleryProvider.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryProvider.japaneseTitle ?? '';
    } else {
      return galleryProvider.englishTitle ?? '';
    }
  }

  Rx<Color?> colorTap = ehTheme.itemBackgroundColor.obs;

  /// 点击item
  void onTap(dynamic tabTag) {
    logger.v('${galleryProvider.englishTitle} ');
    NavigatorUtil.goGalleryPage(
        galleryProvider: galleryProvider, tabTag: tabTag);
  }

  void onTapDown(_) => _updatePressedColor();

  void onTapUp(_) {
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      _updateNormalColor();
    });
  }

  void onTapCancel() => _updateNormalColor();

  void _updateNormalColor() {
    colorTap.value = ehTheme.itemBackgroundColor;
  }

  void _updatePressedColor() {
    colorTap.value = CupertinoDynamicColor.resolve(
        CupertinoColors.systemGrey4, Get.context!);
  }

  set localFav(bool value) {
    galleryProvider.copyWith(localFav: localFav);
    update();
  }

  bool get localFav => galleryProvider.localFav ?? false;

  void firstPutImage(List<GalleryImage> galleryImage) {
    if (galleryImage.isNotEmpty) {
      galleryProvider.copyWith(galleryImages: galleryImage);
    }

    firstPageImage =
        galleryProvider.galleryImages?.sublist(0, galleryImage.length) ?? [];
  }

  /// 长按菜单
  Future<void> _showLongPressSheet() async {
    final BuildContext context = Get.overlayContext!;
    final curPage = Get.currentRoute;
    logger.v('curPage $curPage');
    final curTab = _tabHomeController.currRoute;
    logger.v('curTab $curTab');
    final topRoute = MainNavigatorObserver().history.lastOrNull?.settings.name;

    final isHistoryItem = curPage == EHRoutes.history ||
        topRoute == EHRoutes.history ||
        curTab == EHRoutes.history;
    logger.d('isHistoryItem $isHistoryItem');

    await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(title),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              if (galleryProvider.favcat == null ||
                  (galleryProvider.favcat?.isEmpty ?? false))
                CupertinoActionSheetAction(
                  onPressed: () async {
                    if (galleryProvider.gid == null ||
                        galleryProvider.token == null) {
                      return;
                    }
                    Get.back();

                    try {
                      final value = await _favDialogController.addFav(
                          galleryProvider.gid!, galleryProvider.token!);
                      if (value == null) {
                        return;
                      }
                      setFavTitleAndFavcat(
                          favTitle: value.favTitle, favcat: value.favId);
                      showToast('successfully add');
                    } catch (e) {
                      rethrow;
                    }
                  },
                  child: Text(L10n.of(context).add_to_favorites),
                ),
              if (galleryProvider.favcat != null &&
                  (galleryProvider.favcat?.isNotEmpty ?? false))
                CupertinoActionSheetAction(
                  onPressed: () async {
                    if (galleryProvider.gid == null ||
                        galleryProvider.token == null) {
                      return;
                    }

                    try {
                      await _favDialogController.delFav(galleryProvider.favcat!,
                          galleryProvider.gid!, galleryProvider.token!);
                    } catch (e) {
                      rethrow;
                    }
                    setFavTitleAndFavcat(favTitle: '', favcat: '');
                    showToast('successfully deleted');

                    Get.back();
                  },
                  child: Text(L10n.of(context).remove_from_favorites),
                ),
              if (galleryProvider.favcat != null &&
                  (galleryProvider.favcat?.isNotEmpty ?? false))
                CupertinoActionSheetAction(
                  onPressed: () async {
                    if (galleryProvider.gid == null ||
                        galleryProvider.token == null) {
                      return;
                    }
                    Get.back();

                    try {
                      final value = await _favDialogController.addFav(
                          galleryProvider.gid!, galleryProvider.token!,
                          oriFavcat: galleryProvider.favcat!);
                      if (value != null) {
                        setFavTitleAndFavcat(favTitle: '', favcat: '');
                        setFavTitleAndFavcat(
                            favTitle: value.favTitle, favcat: value.favId);
                        showToast('successfully changed');
                      }
                    } catch (e) {
                      rethrow;
                    }
                  },
                  child: Text(L10n.of(context).change_to_favorites),
                ),
              if (isHistoryItem)
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (galleryProvider.gid == null) {
                      return;
                    }
                    _historyController.removeHistory(galleryProvider.gid!);

                    Get.back();
                  },
                  child: Text(
                    L10n.of(context).delete,
                    style: TextStyle(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.destructiveRed, context),
                    ),
                  ),
                ),
            ],
          );
        });
  }

  void onLongPress() {
    vibrateUtil.heavy();
    _showLongPressSheet();
  }
}
