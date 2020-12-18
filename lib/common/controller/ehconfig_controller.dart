import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class EhConfigController extends ProfileController {
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
    everProfile(isSafeMode, (value) => ehConfig.safeMode = value);

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

    tagTranslatVer.value = ehConfig.tagTranslatVer;
    everProfile(tagTranslatVer, (value) => ehConfig.tagTranslatVer = value);

    lastFavcat.value = ehConfig.lastFavcat ?? '0';
    everProfile(lastFavcat, (value) => ehConfig.lastFavcat);

    isFavPicker.value = ehConfig.favPicker;
    everProfile(isFavPicker, (value) => ehConfig.favPicker);

    isPureDarkTheme.value = ehConfig.pureDarkTheme;
    everProfile<bool>(
        isPureDarkTheme, (bool value) => ehConfig.pureDarkTheme = value);
  }
}
