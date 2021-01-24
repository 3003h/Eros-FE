import 'package:fehviewer/models/base/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:get/get.dart';

class GalleryCacheController extends GetxController {
  final gStore = Get.find<GStore>();

  GalleryCache getGalleryCache(String gid) {
    return gStore.getCache(gid);
  }

  void setIndex(String gid, int index, {bool notify = true}) {
    final GalleryCache _ori = getGalleryCache(gid);
    if (_ori == null) {
      gStore.saveCache(
        GalleryCache()
          ..gid = gid
          ..lastIndex = index,
      );
    } else {
      gStore.saveCache(
        _ori..lastIndex = index,
      );
    }
  }

  void setColumnMode(String gid, ColumnMode columnMode) {
    final GalleryCache _ori = getGalleryCache(gid);
    if (_ori == null) {
      gStore.saveCache(
        GalleryCache()
          ..gid = gid
          ..columnMode = columnMode,
      );
    } else {
      gStore.saveCache(
        _ori..columnMode = columnMode,
      );
    }
  }
}
