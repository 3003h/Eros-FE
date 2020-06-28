import '../ehConfig.dart';
import 'base.dart';

class EhConfigModel extends ProfileChangeNotifier {
  EhConfig get ehConfig => profile.ehConfig;

  bool get isJpnTitle => ehConfig?.jpnTitle ?? false;

  bool get isTagTranslat => ehConfig?.tagTranslat ?? false;

  bool get isGalleryImgBlur => ehConfig?.galleryImgBlur ?? false;

  //更新并通知依赖它的子孙Widgets更新
  set jpnTitle(bool value) {
    profile.ehConfig.jpnTitle = value;
    notifyListeners();
  }

  set tagTranslat(bool value) {
    profile.ehConfig.tagTranslat = value;
    notifyListeners();
  }

  set galleryImgBlur(bool value) {
    profile.ehConfig.galleryImgBlur = value;
    notifyListeners();
  }
}
