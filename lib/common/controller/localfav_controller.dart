import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/utils/toast.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class LocalFavController extends ProfileController {
  RxList<GalleryProvider> loacalFavs = <GalleryProvider>[].obs;

  void addLocalFav(GalleryProvider? galleryProvider) {
    if (galleryProvider == null) {
      return;
    }
    if (loacalFavs
            .indexWhere((element) => element.gid == galleryProvider.gid) ==
        -1) {
      loacalFavs.insert(
        0,
        galleryProvider.copyWith(
          galleryImages: null,
          galleryComment: null,
        ),
      );
    } else {
      showToast('Favorites already exist');
    }
  }

  void removeFav(GalleryProvider? galleryProvider) {
    if (galleryProvider == null) {
      return;
    }
    loacalFavs.removeWhere((element) => element.gid == galleryProvider.gid);
  }

  void removeFavByGid(String gid) {
    loacalFavs.removeWhere((element) => element.gid == gid);
  }

  @override
  void onInit() {
    super.onInit();
    loacalFavs(Global.profile.localFav.gallerys);
    everProfile<List<GalleryProvider>>(
      loacalFavs,
      (List<GalleryProvider> value) {
        Global.profile = Global.profile.copyWith(
          localFav: Global.profile.localFav.copyWith(gallerys: value.oN),
        );
      },
    );
  }
}
