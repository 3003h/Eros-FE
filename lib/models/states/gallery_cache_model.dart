import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/galleryCache.dart';
import 'package:flutter/widgets.dart';

class GalleryCacheModel with ChangeNotifier {
  List<GalleryCache> get _galleryCaches =>
      Global.galleryCaches ?? <GalleryCache>[];

  void _saveCacheAndNotifyListeners({bool notify = true}) {
    Global.saveGalleryCaches();
    if (notify) {
      super.notifyListeners();
    }
  }

  GalleryCache getGalleryCache(String gid) {
    final int _oriIndex =
        _galleryCaches.indexWhere((GalleryCache cache) => cache.gid == gid);
    if (_oriIndex > -1) {
      return _galleryCaches[_oriIndex];
    } else {
      return null;
    }
    ;
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

    _saveCacheAndNotifyListeners(notify: notify);
  }
}
