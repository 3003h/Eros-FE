import 'dart:convert';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get_storage/get_storage.dart';

class GStore {
  static GetStorage _getStore([String container = 'GetStorage']) {
    return GetStorage('GalleryCache', Global.appSupportPath);
  }

  static final _cacheStore = () => _getStore('GalleryCache');
  static final _hisStore = () => _getStore('GalleryHistory');
  static final _profileStore = () => _getStore('Profile');
  static final _downloadStore = () => _getStore('Download');

  static Future<void> init() async {
    await _getStore('GalleryCache').initStorage;
    await _getStore('GalleryHistory').initStorage;
    await _getStore('Profile').initStorage;
    await _getStore('Download').initStorage;
  }

  GalleryCache getCache(String gid) {
    final val = ReadWriteValue(gid, '', _cacheStore).val;
    return val.isNotEmpty ? GalleryCache.fromJson(jsonDecode(val)) : null;
  }

  void saveCache(GalleryCache cache) {
    // logger.d('save cache ${jsonEncode(cache)}');
    ReadWriteValue(cache.gid, '', _cacheStore).val = jsonEncode(cache);
  }

  set tabConfig(TabConfig tabConfig) {
    logger.d('set tabConfig ${tabConfig.toJson()}');
    ReadWriteValue('tabConfig', '', _profileStore).val = jsonEncode(tabConfig);
  }

  TabConfig get tabConfig {
    final val = ReadWriteValue('tabConfig', '', _profileStore).val;
    return val.isNotEmpty ? TabConfig.fromJson(jsonDecode(val)) : null;
  }

  set archiverTaskMap(Map<String, DownloadTaskInfo> dlMap) {
    logger.d(
        'set archiverDlMap \n${dlMap.entries.map((e) => '${e.key} = ${e.value.toJson()}').join('\n')} ');

    // logger.d('jsonEncode(dlMap) => ${jsonEncode(dlMap)}');
    // logger.d(
    //     'jsonEncode() => ${jsonEncode(dlMap.entries.map((e) => e.value).toList())}');

    ReadWriteValue('archiverDlMap', '', _downloadStore).val =
        jsonEncode(dlMap.entries.map((e) => e.value).toList());
  }

  Map<String, DownloadTaskInfo> get archiverTaskMap {
    final val = ReadWriteValue('archiverDlMap', '', _downloadStore).val;

    if (val.isEmpty) {
      return null;
    }

    logger.d('get archiverDlMap ${jsonDecode(val)}');
    final Map<String, DownloadTaskInfo> _map = <String, DownloadTaskInfo>{};
    for (final dynamic dlItemJson in jsonDecode(val) as List<dynamic>) {
      final DownloadTaskInfo _takInfo = DownloadTaskInfo.fromJson(dlItemJson);
      _map[_takInfo.tag] = _takInfo;
    }

    return _map;
  }
}
