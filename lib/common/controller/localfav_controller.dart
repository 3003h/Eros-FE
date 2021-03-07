import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class LocalFavController extends ProfileController {
  RxList<GalleryItem> loacalFavs = <GalleryItem>[].obs;

  void addLocalFav(GalleryItem galleryItem) {
    if (loacalFavs.indexWhere(
            (GalleryItem element) => element.gid == galleryItem.gid) ==
        -1) {
      loacalFavs.insert(0, galleryItem);
    } else {
      showToast('收藏已存在');
    }
  }

  void removeFav(GalleryItem galleryItem) {
    loacalFavs
        .removeWhere((GalleryItem element) => element.gid == galleryItem.gid);
  }

  void removeFavByGid(String gid) {
    loacalFavs.removeWhere((GalleryItem element) => element.gid == gid);
  }

  @override
  void onInit() {
    super.onInit();
    loacalFavs(Global.profile.localFav.gallerys);
    everProfile<List<GalleryItem>>(loacalFavs, (List<GalleryItem> value) {
      // Global.profile.localFav.gallerys = value;
      Global.profile = Global.profile.copyWith(
          localFav: Global.profile.localFav.copyWith(gallerys: value));
    });
  }
}
