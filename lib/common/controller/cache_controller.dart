import 'dart:io' as io;

// import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:eros_fe/common/controller/avatar_controller.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/toast.dart';
import 'package:eros_fe/utils/utility.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../service/dns_service.dart';

class CacheController extends GetxController with StateMixin<String> {
  final DnsService _dnsConfigController = Get.find<DnsService>();
  final AvatarController _avatarController = Get.find();

  @override
  void onInit() {
    super.onInit();
    getTotCacheSize()
        .then((String value) => change(value, status: RxStatus.success()));
  }

  Future<void> clearAllCache() async {
    // DioCacheManager(CacheConfig(databasePath: Global.appSupportPath))
    //     .clearAll();
    Api.cacheOption.store?.clean();
    DefaultCacheManager().emptyCache();
    _dnsConfigController.dohCache.clear();

    _avatarController.clear();

    await _clearCache();

    Future<void>.delayed(const Duration(seconds: 1)).then((_) =>
        getTotCacheSize()
            .then((String value) => change(value, status: RxStatus.success())));

    showToast('Clear cache successfully');
  }

  Future<void> clearDioCache({required String path}) async {
    // DioCacheManager(CacheConfig(databasePath: Global.appSupportPath))
    //     .deleteByPrimaryKey(path, requestMethod: 'GET');
    // DioCacheManager(CacheConfig(databasePath: Global.appSupportPath))
    //     .deleteByPrimaryKey(path, requestMethod: 'POST');

    Api.cacheOption.store?.deleteFromPath(RegExp(path));
  }

  Future<String> getTotCacheSize() async {
    final int _cachesize = await _loadCache();
    // logger.d('tot cacheSize  ${renderSize(_cachesize)}');
    return renderSize(_cachesize);
  }

  Future<int> _getDioCacheSize() async {
    const String _dioCacheName = 'DioCache.db';
    final String _dioCachePath =
        path.join(Global.appSupportPath, _dioCacheName);
    try {
      final io.File _dioCacheFile = io.File(_dioCachePath);
      final int _dioCacheLength = await _dioCacheFile.length();
      logger.d('_dioCacheFile size ${_dioCacheLength - 20480}');
      return _dioCacheLength - 20480;
    } catch (e) {
      logger.e(e.toString());
      return 0;
    }
  }

  ///加载缓存
  Future<int> _loadCache() async {
    try {
      final io.Directory tempDir = io.Directory(Global.tempPath);
      final int value = await _getTotalSizeOfFilesInDir(tempDir);
      // tempDir
      //     .list(followLinks: false, recursive: true)
      //     .listen((io.FileSystemEntity file) {
      //   //打印每个缓存文件的路径
      //   logger.d(file.path);
      // });
      return value;
    } catch (err) {
      logger.e(err);
      return 0;
    }
  }

  /// 递归方式 计算文件的大小
  Future<int> _getTotalSizeOfFilesInDir(final io.FileSystemEntity file) async {
    try {
      if (file is io.File) {
        // logger.d('is file');
        return await file.length();
      }
      if (file is io.Directory) {
        // logger.d('is Directory');
        final List<io.FileSystemEntity> children = file.listSync();
        int total = 0;
        for (final io.FileSystemEntity child in children)
          total += await _getTotalSizeOfFilesInDir(child);
        return total;
      }
      return 0;
    } catch (e) {
      logger.e('$e');
      return 0;
    }
  }

  Future<void> _clearCache() async {
    //此处展示加载loading
    try {
      final io.Directory tempDir = io.Directory(Global.tempPath);
      //删除缓存目录
      await delDir(tempDir);
    } catch (e) {
      logger.e('$e');
    }
  }

  ///递归方式删除目录
  Future<void> delDir(io.FileSystemEntity file) async {
    try {
      if (file is io.Directory) {
        final List<io.FileSystemEntity> children = file.listSync();
        for (final io.FileSystemEntity child in children) {
          await delDir(child);
        }
      }
      if (file is io.File) {
        await file.delete();
      }
    } catch (e) {
      // logger.e('$e');
    }
  }
}
