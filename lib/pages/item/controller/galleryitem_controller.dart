import 'package:collection/collection.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/controller/fav_dialog_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryItemController extends GetxController {
  GalleryItemController();

  final EhConfigService _ehConfigService = Get.find();
  final FavDialogController _favDialogController = Get.find();
  final TabHomeController _tabHomeController = Get.find();
  final HistoryController _historyController = Get.find();

  late List<GalleryImage> firstPageImage;
  late GalleryItem galleryItem;

  /// 点击item
  void onTap(dynamic tabTag) {
    logger.v('${galleryItem.englishTitle} ');
    NavigatorUtil.goGalleryPage(galleryItem: galleryItem, tabTag: tabTag);
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
    logger.d(
        'init GalleryItemController ${galleryItem.gid}  ${galleryItem.englishTitle}');
    if (galleryItem.favTitle != null && galleryItem.favTitle!.isNotEmpty) {
      isFav = true;
    }
    ratingFB = galleryItem.ratingFallBack ?? 0.0;
    logger.d('ratingFB=$ratingFB');
  }

  final RxBool _isFav = false.obs;
  bool get isFav => _isFav.value;
  set isFav(bool val) => _isFav.value = val;

  final _ratingFB = 0.0.obs;
  double get ratingFB => _ratingFB.value;
  set ratingFB(double val) => _ratingFB.value = val;

  void setFavTitleAndFavcat({String favTitle = '', String? favcat}) {
    logger.v('setFavTitle ori isFav :$isFav');
    galleryItem = galleryItem.copyWith(favTitle: favTitle);
    isFav = favTitle.isNotEmpty;
    logger.v('setFavTitle cur isFav :$isFav');
    if (favcat != null || (favcat?.isNotEmpty ?? false)) {
      galleryItem = galleryItem.copyWith(favcat: favcat);
      logger.v('item set favcat $favcat');
    } else {
      galleryItem = galleryItem.copyWith(favcat: '', favTitle: '');
    }
  }

  String get title {
    if ((_ehConfigService.isJpnTitle.value) &&
        (galleryItem.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem.japaneseTitle ?? '';
    } else {
      return galleryItem.englishTitle ?? '';
    }
  }

  Rx<Color?> colorTap = ehTheme.itemBackgroundColor.obs;

  void _updateNormalColor() {
    // colorTap.value = Colors.transparent;
    colorTap.value = ehTheme.itemBackgroundColor;
  }

  void _updatePressedColor() {
    colorTap.value = CupertinoDynamicColor.resolve(
        CupertinoColors.systemGrey4, Get.context!);
  }

  set localFav(bool value) {
    galleryItem = galleryItem.copyWith(localFav: localFav);
    update();
  }

  bool get localFav => galleryItem.localFav ?? false;

  void firstPutImage(List<GalleryImage> galleryImage) {
    if (galleryImage.isNotEmpty) {
      galleryItem = galleryItem.copyWith(galleryImages: galleryImage);
    }

    firstPageImage =
        galleryItem.galleryImages?.sublist(0, galleryImage.length) ?? [];
    // logger.d(' _firstPagePreview ${firstPagePreview.length}');
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
              if (galleryItem.favcat == null ||
                  (galleryItem.favcat?.isEmpty ?? false))
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (galleryItem.gid == null || galleryItem.token == null) {
                      return;
                    }
                    Get.back();
                    _favDialogController
                        .tapAddFav(galleryItem.gid!, galleryItem.token!)
                        .then((Favcat? value) {
                      if (value != null) {
                        setFavTitleAndFavcat(
                            favTitle: value.favTitle, favcat: value.favId);
                        showToast('successfully add');
                      }
                    });
                  },
                  child: Text(L10n.of(context).add_to_favorites),
                ),
              if (galleryItem.favcat != null &&
                  (galleryItem.favcat?.isNotEmpty ?? false))
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (galleryItem.gid == null || galleryItem.token == null) {
                      return;
                    }
                    _favDialogController
                        .delFav(galleryItem.favcat!, galleryItem.gid!,
                            galleryItem.token!)
                        .then((_) {
                      setFavTitleAndFavcat(favTitle: '', favcat: '');
                      showToast('successfully deleted');
                    });
                    Get.back();
                  },
                  child: Text(L10n.of(context).remove_from_favorites),
                ),
              if (galleryItem.favcat != null &&
                  (galleryItem.favcat?.isNotEmpty ?? false))
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (galleryItem.gid == null || galleryItem.token == null) {
                      return;
                    }
                    Get.back();
                    _favDialogController
                        .tapAddFav(galleryItem.gid!, galleryItem.token!,
                            oriFavcat: galleryItem.favcat!)
                        .then((Favcat? value) {
                      if (value != null) {
                        setFavTitleAndFavcat(favTitle: '', favcat: '');
                        setFavTitleAndFavcat(
                            favTitle: value.favTitle, favcat: value.favId);
                        showToast('successfully changed');
                      }
                    });
                  },
                  child: Text(L10n.of(context).change_to_favorites),
                ),
              if (isHistoryItem)
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (galleryItem.gid == null) {
                      return;
                    }
                    _historyController.removeHistory(galleryItem.gid!);

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
