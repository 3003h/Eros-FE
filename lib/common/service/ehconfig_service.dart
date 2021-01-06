import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EhConfigService extends ProfileService {
  RxBool isJpnTitle = false.obs;
  RxBool isTagTranslat = false.obs;
  RxBool isGalleryImgBlur = false.obs;
  RxBool isSiteEx = false.obs;
  RxBool isFavLongTap = false.obs;
  RxInt catFilter = 0.obs;
  Rx<ListModeEnum> listMode = ListModeEnum.list.obs;
  RxInt maxHistory = 100.obs;
  RxBool isSearchBarComp = true.obs;
  Rx<FavoriteOrder> favoriteOrder = FavoriteOrder.fav.obs;
  RxBool isSafeMode = false.obs;
  RxString tagTranslatVer = ''.obs;
  RxString lastFavcat = '0'.obs;
  RxBool isFavPicker = false.obs;
  RxBool isPureDarkTheme = false.obs;

  String get lastShowFavcat => ehConfig.lastShowFavcat;

  set lastShowFavcat(String value) {
    ehConfig.lastShowFavcat = value;
    Global.saveProfile();
  }

  String get lastShowFavTitle => ehConfig.lastShowFavTitle;

  set lastShowFavTitle(String value) {
    ehConfig.lastShowFavTitle = value;
    Global.saveProfile();
  }

  /// 预载图片数量
  RxInt preloadImage = 5.obs;

  /// 阅读方向
  Rx<ViewMode> viewMode = ViewMode.horizontalLeft.obs;

  @override
  void onInit() {
    super.onInit();

    ehConfig = Global.profile.ehConfig;
    downloadConfig = Global.profile.downloadConfig;

    /// 预载图片数量
    preloadImage.value = downloadConfig.preloadImage ?? 5;
    everProfile(preloadImage, (value) => downloadConfig.preloadImage = value);

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, ehConfig?.viewModel) ??
            ViewMode.horizontalLeft;
    everFromEunm(viewMode, (String value) => ehConfig.viewModel = value);

    //
    isSafeMode.value = ehConfig.safeMode ?? true;
    everProfile(isSafeMode, (value) {
      ehConfig.safeMode = value;
      Get.find<TabHomeController>().resetIndex();
    });

    isJpnTitle.value = ehConfig?.jpnTitle ?? false;
    everProfile(isJpnTitle, (value) => ehConfig.jpnTitle = value);

    isTagTranslat.value = ehConfig?.tagTranslat ?? false;
    everProfile(isTagTranslat, (value) => ehConfig.tagTranslat = value);

    isGalleryImgBlur.value = ehConfig?.galleryImgBlur ?? false;
    everProfile(isGalleryImgBlur, (value) => ehConfig.galleryImgBlur = value);

    isSiteEx.value = ehConfig?.siteEx ?? false;
    everProfile(isSiteEx, (value) => ehConfig.siteEx = value);

    isFavLongTap.value = ehConfig?.favLongTap ?? false;
    everProfile(isFavLongTap, (value) => ehConfig.favLongTap = value);

    catFilter.value = ehConfig.catFilter ?? 0;
    everProfile(catFilter, (value) => ehConfig.catFilter = value);

    listMode.value =
        EnumToString.fromString(ListModeEnum.values, ehConfig?.listMode) ??
            ListModeEnum.list;
    everFromEunm(listMode, (String value) => ehConfig.listMode = value);

    maxHistory.value = ehConfig.maxHistory ?? 100;
    everProfile(maxHistory, (value) => ehConfig.maxHistory = value);

    isSearchBarComp.value = ehConfig.searchBarComp ?? true;
    everProfile(isSearchBarComp, (value) => ehConfig.searchBarComp = value);

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, ehConfig?.favoritesOrder) ??
        FavoriteOrder.fav;
    everFromEunm(
        favoriteOrder, (String value) => ehConfig.favoritesOrder = value);

    tagTranslatVer.value = ehConfig.tagTranslatVer ?? '';
    everProfile(tagTranslatVer, (value) => ehConfig.tagTranslatVer = value);

    lastFavcat.value = ehConfig.lastFavcat ?? '0';
    everProfile(lastFavcat, (value) => ehConfig.lastFavcat);

    isFavPicker.value = ehConfig.favPicker ?? false;
    everProfile(isFavPicker, (value) => ehConfig.favPicker);

    isPureDarkTheme.value = ehConfig.pureDarkTheme ?? false;
    everProfile<bool>(
        isPureDarkTheme, (bool value) => ehConfig.pureDarkTheme = value);
  }

  /// 收藏排序
  Future<FavoriteOrder> showFavOrder() async {
    final BuildContext context = Get.context;
    final Map<FavoriteOrder, String> _orderMap = <FavoriteOrder, String>{
      FavoriteOrder.posted: S.of(context).favorites_order_Use_posted,
      FavoriteOrder.fav: S.of(context).favorites_order_Use_favorited,
    };

    List<Widget> _getOrderList(BuildContext context) {
      return List<Widget>.from(_orderMap.keys.map((FavoriteOrder element) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Get.back(result: element);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (element == favoriteOrder.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(CupertinoIcons.checkmark),
                  ),
                Text(_orderMap[element]),
              ],
            ));
      }).toList());
    }

    final FavoriteOrder _result = await showCupertinoModalPopup<FavoriteOrder>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(S.of(context).favorites_order),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
            actions: <Widget>[
              ..._getOrderList(context),
            ],
          );
        });

    if (_result != null) {
      logger.v('to ${EnumToString.convertToString(_result)}');
      if (favoriteOrder.value != _result) {
        return favoriteOrder.value = _result;
      } else {
        return null;
      }
    }
    return _result;
  }
}
