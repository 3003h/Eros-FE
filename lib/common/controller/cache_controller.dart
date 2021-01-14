import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../service/dns_service.dart';

class CacheController extends GetxController {
  final DnsService _dnsConfigController = Get.find<DnsService>();

  void clearAllCache() {
    DioCacheManager(CacheConfig(databasePath: Global.appSupportPath))
        .clearAll();
    DefaultCacheManager().emptyCache();
    _dnsConfigController.dohCache.clear();

    showToast('Clear cache successfully');
  }
}
