import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';

class EhConfigController extends GetxController {
  EhConfig _ehConfig;
  DownloadConfig _downloadConfig;

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

  /// 预载图片数量
  RxInt preloadImage = 5.obs;

  /// 阅读方向
  Rx<ViewMode> viewMode = ViewMode.horizontalLeft.obs;

  @override
  void onInit() {
    super.onInit();
    _ehConfig = Global.profile.ehConfig;
    _downloadConfig = Global.profile.downloadConfig;

    /// 预载图片数量
    preloadImage.value = _downloadConfig.preloadImage ?? 5;
    everSaveProfile(preloadImage, _downloadConfig.preloadImage);

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, _ehConfig?.viewModel) ??
            ViewMode.horizontalLeft;
    everSaveProfile(viewMode, _ehConfig.viewModel, isEnum: true);

    //
    isSafeMode.value = _ehConfig.safeMode ?? true;
    everSaveProfile(isSafeMode, _ehConfig.safeMode);

    isJpnTitle.value = _ehConfig?.jpnTitle ?? false;
    everSaveProfile(isJpnTitle, _ehConfig.jpnTitle);

    isTagTranslat.value = _ehConfig?.tagTranslat ?? false;
    everSaveProfile(isTagTranslat, _ehConfig.tagTranslat);

    isGalleryImgBlur.value = _ehConfig?.galleryImgBlur ?? false;
    everSaveProfile(isGalleryImgBlur, _ehConfig.galleryImgBlur);

    isSiteEx.value = _ehConfig?.siteEx ?? false;
    everSaveProfile(isSiteEx, _ehConfig.siteEx);

    isFavLongTap.value = _ehConfig?.favLongTap ?? false;
    everSaveProfile(isFavLongTap, _ehConfig.favLongTap);

    catFilter.value = _ehConfig.catFilter ?? 0;
    everSaveProfile(catFilter, _ehConfig.catFilter);

    listMode.value =
        EnumToString.fromString(ListModeEnum.values, _ehConfig?.listMode) ??
            ListModeEnum.list;
    everSaveProfile(listMode, _ehConfig.listMode, isEnum: true);

    maxHistory.value = _ehConfig.maxHistory ?? 100;
    everSaveProfile(maxHistory, _ehConfig.maxHistory);

    isSearchBarComp.value = _ehConfig.searchBarComp ?? true;
    everSaveProfile(isSearchBarComp, _ehConfig.searchBarComp);

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, _ehConfig?.favoritesOrder) ??
        FavoriteOrder.fav;
    everSaveProfile(favoriteOrder, _ehConfig.favoritesOrder, isEnum: true);
  }

  void everSaveProfile<T>(RxInterface<T> listener, saveto,
      {bool isEnum = false}) {
    ever<T>(listener, (T value) {
      saveto = isEnum ? EnumToString.convertToString(value) : value;
      Global.saveProfile();
    });
  }
}
