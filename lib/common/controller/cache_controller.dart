import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class CacheController extends GetxController {
  void clearAllCache() {
    DioCacheManager(CacheConfig(databasePath: Global.appSupportPath))
        .clearAll();
    DefaultCacheManager().emptyCache();
  }
}
