import 'dart:convert';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get_storage/get_storage.dart';

class GStore {
  static GetStorage _getStore([String container = 'GetStorage']) {
    return GetStorage('GalleryCache', Global.appSupportPath);
  }

  GetStorage _cacheStore() => _getStore('GalleryCache');
  GetStorage _hisStore() => _getStore('GalleryHistory');
  GetStorage _profileStore() => _getStore('Profile');
  GetStorage _downloadStore() => _getStore('Download');

  static Future<void> init() async {
    await _getStore('GalleryCache').initStorage;
    await _getStore('GalleryHistory').initStorage;
    await _getStore('Profile').initStorage;
    await _getStore('Download').initStorage;
  }

  @Deprecated('use hive')
  GalleryCache? getCache(String gid) {
    final val = ReadWriteValue(gid, '', _cacheStore).val;
    return val.isNotEmpty
        ? GalleryCache.fromJson(jsonDecode(val) as Map<String, dynamic>)
        : null;
  }

  @Deprecated('use hive')
  void saveCache(GalleryCache cache) {
    if (cache.gid != null) {
      ReadWriteValue(cache.gid!, '', _cacheStore).val = jsonEncode(cache);
    }
  }

  @Deprecated('use [Global.profile]')
  set tabConfig(TabConfig? tabConfig) {
    logger.d('set tabConfig ${tabConfig?.toJson()}');
    ReadWriteValue('tabConfig', '', _profileStore).val = jsonEncode(tabConfig);
  }

  @Deprecated('use [Global.profile]')
  TabConfig? get tabConfig {
    final String val =
        ReadWriteValue('tabConfig', '{"tab_item_list": []}', _profileStore).val;
    final _config = jsonDecode(val);
    if (_config['tab_item_list'] == null) {
      _config['tab_item_list'] = _config['tabItemList'];
    }
    return val.isNotEmpty
        ? TabConfig.fromJson(_config as Map<String, dynamic>)
        : null;
  }

  @Deprecated('hive archiverTaskMap')
  set archiverTaskMap(Map<String, DownloadArchiverTaskInfo>? taskInfoMap) {
    logger.v('set archiverDlMap \n'
        '${taskInfoMap?.entries.map((e) => '${e.key} = ${e.value.toJson().toString().split(', ').join('\n')}').join('\n')} ');

    if (taskInfoMap == null) {
      return;
    }

    ReadWriteValue('archiverTaskMap', '', _downloadStore).val =
        jsonEncode(taskInfoMap.entries.map((e) => e.value).toList());
  }

  void cleanArchiverTaskMap() {
    ReadWriteValue('archiverTaskMap', '', _downloadStore).val = '';
  }

  @Deprecated('hive archiverTaskMap')
  Map<String, DownloadArchiverTaskInfo>? get archiverTaskMap {
    final val = ReadWriteValue('archiverTaskMap', '', _downloadStore).val;

    if (val.isEmpty) {
      return null;
    }
    final _map = <String, DownloadArchiverTaskInfo>{};
    for (final dynamic dlItemJson in jsonDecode(val) as List<dynamic>) {
      final _takInfo =
          DownloadArchiverTaskInfo.fromJson(dlItemJson as Map<String, dynamic>);
      if (_takInfo.tag != null) {
        _map[_takInfo.tag!] = _takInfo;
      }
    }

    return _map;
  }

  @Deprecated('use hive')
  Profile get profile {
    final String val = ReadWriteValue('profile', '{}', _profileStore).val;
    final Profile _profileObj =
        Profile.fromJson(jsonDecode(val) as Map<String, dynamic>);
    // logger.v('_initProfile \n${_profileObj.toJson()}');
    final Profile _profile = kDefProfile.copyWith(
      user: _profileObj.user,
      ehConfig: _profileObj.ehConfig,
      lastLogin: _profileObj.lastLogin,
      locale: _profileObj.locale,
      theme: _profileObj.theme,
      searchText: _profileObj.searchText,
      localFav: _profileObj.localFav,
      enableAdvanceSearch: _profileObj.enableAdvanceSearch,
      advanceSearch: _profileObj.advanceSearch,
      dnsConfig: _profileObj.dnsConfig,
      downloadConfig: _profileObj.downloadConfig,
      webdav: _profileObj.webdav,
      autoLock: _profileObj.autoLock,
      favConfig: _profileObj.favConfig,
      customTabConfig: _profileObj.customTabConfig,
    );
    return _profile;
  }

  @Deprecated('use hive')
  set profile(Profile val) {
    ReadWriteValue('profile', '{}', _profileStore).val = jsonEncode(val);
  }
}
