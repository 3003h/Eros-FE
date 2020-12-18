import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:get/get.dart';

class GalleryCacheController extends GetxController {
  List<GalleryCache> get _galleryCaches =>
      Global.galleryCaches ?? <GalleryCache>[];

  GalleryCache getGalleryCache(String gid) {
    final int _oriIndex =
        _galleryCaches.indexWhere((GalleryCache cache) => cache.gid == gid);
    if (_oriIndex > -1) {
      return _galleryCaches[_oriIndex];
    } else {
      return null;
    }
  }

  void setIndex(String gid, int index, {bool notify = true}) {
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
  }
}
