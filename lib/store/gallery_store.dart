import 'dart:convert';

import 'package:fehviewer/models/index.dart';
import 'package:get_storage/get_storage.dart';

class GStore {
  static final _cacheStore = () => GetStorage('GalleryCache');

  GalleryCache getCache(String gid) {
    final val = ReadWriteValue(gid, '', _cacheStore).val;
    return val.isNotEmpty ? GalleryCache.fromJson(jsonDecode(val)) : null;
  }

  void saveCache(GalleryCache cache) {
    // logger.d('save cache ${jsonEncode(cache)}');
    ReadWriteValue(cache.gid, '', _cacheStore).val = jsonEncode(cache);
  }
}
