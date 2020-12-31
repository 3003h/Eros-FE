import 'package:fehviewer/models/base/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_view/controller/view_controller.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:get/get.dart';

class GalleryCacheController extends GetxController {
  // List<GalleryCache> get _galleryCaches =>
  //     Global.galleryCaches ?? <GalleryCache>[];

  final gStore = Get.find<GStore>();

  GalleryCache getGalleryCache(String gid) {
/*
    final int _oriIndex =
        _galleryCaches.indexWhere((GalleryCache cache) => cache.gid == gid);
    if (_oriIndex > -1) {
      return _galleryCaches[_oriIndex];
    } else {
      return null;
    }
*/
    return gStore.getCache(gid);
  }

  void setIndex(String gid, int index, {bool notify = true}) {
/*
    final int _oriIndex =
        _galleryCaches.indexWhere((GalleryCache cache) => cache.gid == gid);
    if (_oriIndex > -1) {
      _galleryCaches[_oriIndex].lastIndex = index;
    } else {
      _galleryCaches.add(GalleryCache()
        ..gid = gid
        ..lastIndex = index);
    }

    Global.saveGalleryCaches();
*/
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
