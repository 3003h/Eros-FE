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

  GalleryCache? getCache(String gid) {
    final val = ReadWriteValue(gid, '', _cacheStore).val;
    return val.isNotEmpty ? GalleryCache.fromJson(jsonDecode(val)) : null;
  }

  void saveCache(GalleryCache cache) {
    // logger.d('save cache ${jsonEncode(cache)}');
    ReadWriteValue(cache.gid, '', _cacheStore).val = jsonEncode(cache);
  }

  set tabConfig(TabConfig? tabConfig) {
    logger.d('set tabConfig ${tabConfig?.toJson()}');
    ReadWriteValue('tabConfig', '', _profileStore).val = jsonEncode(tabConfig);
  }

  TabConfig? get tabConfig {
    final String val =
        ReadWriteValue('tabConfig', '{"tab_item_list": []}', _profileStore).val;
    // logger.v('${jsonDecode(val)}');
    final _config = jsonDecode(val);
    if (_config['tab_item_list'] == null) {
      _config['tab_item_list'] = _config['tabItemList'];
    }
    return val.isNotEmpty ? TabConfig.fromJson(_config) : null;
  }

  set archiverTaskMap(Map<String, DownloadTaskInfo>? taskInfoMap) {
    logger.d('set archiverDlMap \n'
        '${taskInfoMap?.entries.map((e) => '${e.key} = ${e.value.toJson().toString().split(', ').join('\n')}').join('\n')} ');

    if (taskInfoMap == null) {
      return;
    }

    ReadWriteValue('archiverTaskMap', '', _downloadStore).val =
        jsonEncode(taskInfoMap.entries.map((e) => e.value).toList());
  }

  Map<String, DownloadTaskInfo>? get archiverTaskMap {
    final val = ReadWriteValue('archiverTaskMap', '', _downloadStore).val;

    if (val.isEmpty) {
      return null;
    }

    logger.d('get archiverDlMap ${jsonDecode(val)}');
    final Map<String, DownloadTaskInfo> _map = <String, DownloadTaskInfo>{};
    for (final dynamic dlItemJson in jsonDecode(val) as List<dynamic>) {
      final DownloadTaskInfo _takInfo = DownloadTaskInfo.fromJson(dlItemJson);
      if (_takInfo.tag != null) {
        _map[_takInfo.tag!] = _takInfo;
      }
    }

    return _map;
  }

  set searchHistory(List<String> val) {
    logger.d('set searchHistory ${val.join(',')}');
    ReadWriteValue('searchHistory', '', _hisStore).val = jsonEncode(val);
  }

  List<String> get searchHistory {
    final String val = ReadWriteValue('searchHistory', '', _hisStore).val;

    logger.d('get searchHistory $val');

    List<String> rult = <String>[];
    if (val == null || val.trim().isEmpty) {
      return rult;
    }
    for (final dynamic his in jsonDecode(val) as List<dynamic>) {
      final String _his = his;
      rult.add(_his);
    }

    return rult;
  }
}
