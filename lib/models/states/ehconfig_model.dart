import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:enum_to_string/enum_to_string.dart';

import '../ehConfig.dart';
import 'base.dart';

class EhConfigModel extends ProfileChangeNotifier {
  EhConfig get _ehConfig => Global.profile.ehConfig;

  bool get isJpnTitle => _ehConfig?.jpnTitle ?? false;

  bool get isTagTranslat => _ehConfig?.tagTranslat ?? false;

  bool get isGalleryImgBlur => _ehConfig?.galleryImgBlur ?? false;

  //更新并通知依赖它的子孙Widgets更新
  bool get siteEx => _ehConfig.siteEx ?? false;

  set siteEx(bool value) {
    _ehConfig.siteEx = value;
    notifyListeners();
  }

  bool get favLongTap => _ehConfig.favLongTap ?? false;

  set favLongTap(bool value) {
    _ehConfig.favLongTap = value;
    notifyListeners();
  }

  bool get jpnTitle => _ehConfig.jpnTitle ?? false;

  set jpnTitle(bool value) {
    _ehConfig.jpnTitle = value;
    notifyListeners();
  }

  bool get tagTranslat => _ehConfig.tagTranslat ?? false;

  set tagTranslat(bool value) {
    _ehConfig.tagTranslat = value;
    notifyListeners();
  }

  bool get galleryImgBlur => _ehConfig.galleryImgBlur ?? false;

  set galleryImgBlur(bool value) {
    _ehConfig.galleryImgBlur = value;
    notifyListeners();
  }

  int get catFilter => _ehConfig.catFilter ?? 0;

  set catFilter(int value) {
    _ehConfig.catFilter = value;
    notifyListeners();
  }

  ListModeEnum get listMode =>
      EnumToString.fromString(ListModeEnum.values, _ehConfig?.listMode) ??
      ListModeEnum.list;

  set listMode(ListModeEnum mode) {
    _ehConfig.listMode = EnumToString.convertToString(mode);
    notifyListeners();
  }

  int get maxHistory => _ehConfig.maxHistory ?? 100;
  set maxHistory(int max) {
    _ehConfig.maxHistory = max;
    notifyListeners();
  }

  bool get searchBarComp => _ehConfig.searchBarComp ?? true;

  set searchBarComp(bool value) {
    _ehConfig.searchBarComp = value;
    notifyListeners();
  }

  // 设网络收藏夹排序方式
  FavoriteOrder get favoriteOrder =>
      EnumToString.fromString(
          FavoriteOrder.values, _ehConfig?.favoritesOrder) ??
      FavoriteOrder.fav;

  set favoriteOrder(FavoriteOrder favoriteOrder) {
    _ehConfig.favoritesOrder = EnumToString.convertToString(favoriteOrder);
    notifyListeners();
  }

  bool get isSafeMode => _ehConfig.safeMode;
  set isSafeMode(bool value) {
    _ehConfig.safeMode = value;
    notifyListeners();
  }
}
