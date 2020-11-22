import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/profile.dart';
import 'package:FEhViewer/utils/toast.dart';

import 'base.dart';

class LocalFavModel extends ProfileChangeNotifier {
  Profile get _profile => Global.profile;

  List<GalleryItem> get loacalFavs =>
      _profile.localFav.gallerys ?? <GalleryItem>[];

  void addLocalFav(GalleryItem galleryItem) {
    // Global.logger.v('${galleryItem.toJson()}');
    if (loacalFavs.indexWhere((element) => element.gid == galleryItem.gid) ==
        -1) {
      _profile.localFav.gallerys.insert(0, galleryItem);
      Global.logger.v('${_profile.localFav.gallerys.length}');
      notifyListeners();
    } else {
      showToast('收藏已存在');
    }
  }

  void removeFav(GalleryItem galleryItem) {
    _profile.localFav.gallerys
        .removeWhere((GalleryItem element) => element.gid == galleryItem.gid);
    notifyListeners();
  }
}
