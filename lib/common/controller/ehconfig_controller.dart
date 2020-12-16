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
    everSaveProfile(
        preloadImage, (value) => downloadConfig.preloadImage = value);

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, ehConfig?.viewModel) ??
            ViewMode.horizontalLeft;
    everSaveProfile(viewMode, (value) => ehConfig.viewModel = value,
        isEnum: true);

    //
    isSafeMode.value = ehConfig.safeMode ?? true;
    everSaveProfile(isSafeMode, (value) => ehConfig.safeMode = value);

    isJpnTitle.value = ehConfig?.jpnTitle ?? false;
    everSaveProfile(isJpnTitle, (value) => ehConfig.jpnTitle = value);

    isTagTranslat.value = ehConfig?.tagTranslat ?? false;
    everSaveProfile(isTagTranslat, (value) => ehConfig.tagTranslat = value);

    isGalleryImgBlur.value = ehConfig?.galleryImgBlur ?? false;
    everSaveProfile(
        isGalleryImgBlur, (value) => ehConfig.galleryImgBlur = value);

    isSiteEx.value = ehConfig?.siteEx ?? false;
    everSaveProfile(isSiteEx, (value) => ehConfig.siteEx = value);

    isFavLongTap.value = ehConfig?.favLongTap ?? false;
    everSaveProfile(isFavLongTap, (value) => ehConfig.favLongTap = value);

    catFilter.value = ehConfig.catFilter ?? 0;
    everSaveProfile(catFilter, (value) => ehConfig.catFilter = value);

    listMode.value =
        EnumToString.fromString(ListModeEnum.values, ehConfig?.listMode) ??
            ListModeEnum.list;
    everSaveProfile(listMode, (value) => ehConfig.listMode = value,
        isEnum: true);

    maxHistory.value = ehConfig.maxHistory ?? 100;
    everSaveProfile(maxHistory, (value) => ehConfig.maxHistory = value);

    isSearchBarComp.value = ehConfig.searchBarComp ?? true;
    everSaveProfile(isSearchBarComp, (value) => ehConfig.searchBarComp = value);

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, ehConfig?.favoritesOrder) ??
        FavoriteOrder.fav;
    everSaveProfile(favoriteOrder, (value) => ehConfig.favoritesOrder = value,
        isEnum: true);

    tagTranslatVer.value = ehConfig.tagTranslatVer;
    everSaveProfile(tagTranslatVer, (value) => ehConfig.tagTranslatVer = value);

    lastFavcat.value = ehConfig.lastFavcat ?? '0';
    everSaveProfile(lastFavcat, (value) => ehConfig.lastFavcat);

    isFavPicker.value = ehConfig.favPicker;
    everSaveProfile(isFavPicker, (value) => ehConfig.favPicker);
  }
}
