import 'dart:collection';
import 'dart:convert';

import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

class GalleryCacheController extends GetxController {
  final GStore gStore = Get.find<GStore>();
  LinkedHashMap<String, GalleryCache> gCacheMap = LinkedHashMap();

  GalleryCache? getGalleryCache(String gid) {
    final _cache = gStore.getCache(gid);
    if (!gCacheMap.containsKey(gid) && _cache != null) {
      logger.v('get from store');
      gCacheMap[gid] = _cache;
    }

    return gCacheMap[gid];
  }

  void setIndex(String gid, int index, {bool saveToStore = false}) {
    final GalleryCache? _ori = getGalleryCache(gid);
    if (_ori == null) {
      gCacheMap[gid] = GalleryCache(gid: gid, lastIndex: index);
      if (saveToStore) {
        gStore.saveCache(GalleryCache(gid: gid, lastIndex: index));
      }
    } else {
      gCacheMap[gid] = _ori.copyWith(lastIndex: index);
      if (saveToStore) {
        gStore.saveCache(_ori.copyWith(lastIndex: index));
      }
    }
  }

  void saveAll() {
    logger.v(
        'save All GalleryCache \n${gCacheMap.entries.map((e) => jsonEncode(e.value)).join('\n')}');
    gCacheMap.forEach((key, value) {
      gStore.saveCache(value);
    });
  }

  void setColumnMode(String gid, ViewColumnMode columnMode) {
    final GalleryCache? _ori = getGalleryCache(gid);
    if (_ori == null) {
      gCacheMap[gid] = GalleryCache(gid: gid).copyWithMode(columnMode);
      gStore.saveCache(GalleryCache(gid: gid).copyWithMode(columnMode));
    } else {
      gCacheMap[gid] = _ori.copyWithMode(columnMode);
      gStore.saveCache(_ori.copyWithMode(columnMode));
    }
  }
}
