import 'dart:convert';

import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String historyBox = 'history_box';
const String historyDelBox = 'history_del_box';
const String searchHistoryBox = 'search_history_box';
const String configBox = 'config_box';
const String archiverTaskBox = 'archiver_task_box';
const String galleryCacheBox = 'gallery_cache_box';

const String searchHistoryKey = 'search_history';
const String layoutConfigKey = 'config_layout';
const String usersKey = 'users_info';
const String profileDelKey = 'delete_profile';
const String qsLastTimeKey = 'quick_search_last_edit_time';
const String customImageHideKey = 'custom_image_hide';
const String profileKey = 'profile';

const String ehHomeKey = 'eh_home';
const String viewHistoryMigrationKey = 'viewHistoryMigration';
const String downloadTaskMigrationKey = 'downloadTaskMigration';

class HiveHelper {
  HiveHelper();
  static final _historyBox = Hive.box<String>(historyBox);
  static final _historyDelBox = Hive.box<String>(historyDelBox);
  static final _searchHistoryBox = Hive.box<String>(searchHistoryBox);
  static final _archiverTaskBox = Hive.box<String>(archiverTaskBox);
  static final _galleryCacheBox = Hive.box<String>(galleryCacheBox);
  static final _configBox = Hive.box<String>(configBox);

  Future<void> init([String? subDir]) async {
    await Hive.initFlutter(subDir);
    await Hive.openBox<String>(
      historyBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.t('entries $entries');
        return entries > 10;
      },
    );

    // open galleryCacheBox
    await Hive.openBox<String>(
      galleryCacheBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.t('entries $entries');
        return entries > 10;
      },
    );

    await Hive.openBox<String>(
      historyDelBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.t('entries $entries');
        return entries > 10;
      },
    );
    await Hive.openBox<String>(searchHistoryBox,
        compactionStrategy: (int entries, int deletedEntries) {
      logger.t('$searchHistoryBox entries $entries');
      return true;
    });

    await Hive.openBox<String>(
      archiverTaskBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.t('entries $entries');
        return entries > 10;
      },
    );

    await Hive.openBox<String>(
      configBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.t('$configBox entries $entries');
        return entries > 2;
      },
    );
  }

  List<GalleryProvider> getAllHistory() {
    final _histories = <GalleryProvider>[];
    for (final val in _historyBox.values) {
      _histories.add(
          GalleryProvider.fromJson(jsonDecode(val) as Map<String, dynamic>));
    }
    _histories
        .sort((a, b) => (a.lastViewTime ?? 0).compareTo(b.lastViewTime ?? 0));
    return _histories;
  }

  List<String> getAllSearchHistory() {
    final result = <String>[];
    final String? val =
        _searchHistoryBox.get(searchHistoryKey, defaultValue: '[]');
    for (final dynamic his in jsonDecode(val ?? '[]') as List<dynamic>) {
      final String _his = his as String;
      result.add(_his);
    }
    return result;
  }

  Future<void> addHistoryDel(HistoryIndexGid gi) async {
    final gid = gi.g;
    await _historyDelBox.put(gid, jsonEncode(gi));
  }

  List<HistoryIndexGid> getAllHistoryDel() {
    final _delHistories = <HistoryIndexGid>[];
    for (final val in _historyDelBox.values) {
      _delHistories.add(
          HistoryIndexGid.fromJson(jsonDecode(val) as Map<String, dynamic>));
    }
    return _delHistories;
  }

  Future<void> removeHistoryDel(String gid) async {
    _historyDelBox.delete(gid);
  }

  Future<void> setSearchHistory(List<String> searchTexts) async {
    await _searchHistoryBox.put(searchHistoryKey, jsonEncode(searchTexts));
  }

  Future<void> setEhLayout(EhLayout ehLayout) async {
    await _configBox.put(layoutConfigKey, jsonEncode(ehLayout));
  }

  EhLayout getEhLayout() {
    final val = _configBox.get(layoutConfigKey, defaultValue: '{}');
    return EhLayout.fromJson(jsonDecode(val ?? '{}') as Map<String, dynamic>);
  }

  // Future<void> setUsersInfo(List<User> users) async {
  //   await _configBox.put(usersKey, jsonEncode(users));
  // }

  // List<User> getUsersInfo() {
  //   final all = _configBox.get(usersKey, defaultValue: '[]');
  //
  //   final _users = <User>[];
  //   for (final val in jsonDecode(all ?? '[]') as List<dynamic>) {
  //     _users.add(User.fromJson(val as Map<String, dynamic>));
  //   }
  //   return _users;
  // }

  void clearUsersInfo() {
    _configBox.delete(usersKey);
  }

  Future<void> setProfileDelList(List<CustomProfile> delProfiles) async {
    await _configBox.put(profileDelKey, jsonEncode(delProfiles));
  }

  List<CustomProfile> getProfileDelList() {
    final all = _configBox.get(profileDelKey, defaultValue: '[]');

    final _delProfiles = <CustomProfile>[];
    for (final val in jsonDecode(all ?? '[]') as List<dynamic>) {
      _delProfiles.add(CustomProfile.fromJson(val as Map<String, dynamic>));
    }
    return _delProfiles;
  }

  int getQuickSearchLastEditTime() {
    const _time = '0';
    final val = _configBox.get(qsLastTimeKey, defaultValue: _time);
    return int.parse(val ?? _time);
  }

  Future<void> setQuickSearchLastEditTime(int time) async {
    await _configBox.put(qsLastTimeKey, '$time');
  }

  Future<void> setAllCustomImageHide(List<ImageHide> imageHides) async {
    await _configBox.put(customImageHideKey, jsonEncode(imageHides));
  }

  List<ImageHide> getAllCustomImageHide() {
    final all = _configBox.get(customImageHideKey, defaultValue: '[]');

    final _imageHides = <ImageHide>[];
    for (final val in jsonDecode(all ?? '[]') as List<dynamic>) {
      _imageHides.add(ImageHide.fromJson(val as Map<String, dynamic>));
    }
    return _imageHides;
  }

  Future<void> setEhHome(EhHome ehHome) async {
    await _configBox.put(ehHomeKey, jsonEncode(ehHome));
  }

  EhHome getEhHome() {
    final val = _configBox.get(ehHomeKey, defaultValue: '{}');

    return EhHome.fromJson(jsonDecode(val ?? '{}') as Map<String, dynamic>);
  }

  String? getString(String key) {
    return _configBox.get(key, defaultValue: '');
  }

  Future<void> setString(String key, String value) async {
    await _configBox.put(key, value);
  }

  bool getViewHistoryMigration() {
    return _configBox.get(viewHistoryMigrationKey) == 'true';
  }

  Future<void> setViewHistoryMigration(bool value) async {
    await _configBox.put(viewHistoryMigrationKey, '$value');
  }

  bool getDownloadTaskMigration() {
    return _configBox.get(downloadTaskMigrationKey) == 'true';
  }

  Future<void> setDownloadTaskMigration(bool value) async {
    await _configBox.put(downloadTaskMigrationKey, '$value');
  }

  void putAllArchiverTaskMap(
      Map<String, DownloadArchiverTaskInfo>? taskInfoMap) {
    // len
    logger.d('set archiverTaskMap len ${taskInfoMap?.length}');
    logger.t('set archiverDlMap \n'
        '${taskInfoMap?.entries.map((e) => '${e.key} = ${e.value.toJson().toString().split(', ').join('\n')}').join('\n')} ');

    if (taskInfoMap == null) {
      return;
    }

    for (final entry in taskInfoMap.entries) {
      _archiverTaskBox.put(entry.key, jsonEncode(entry.value));
    }
  }

  void putArchiverTask(DownloadArchiverTaskInfo? taskInfo) {
    if (taskInfo == null) {
      return;
    }
    logger.t('set archiverTask ${taskInfo.toJson()}');
    _archiverTaskBox.put(taskInfo.tag, jsonEncode(taskInfo));
  }

  void removeArchiverTask(String? tag) {
    _archiverTaskBox.delete(tag);
  }

  Map<String, DownloadArchiverTaskInfo>? getAllArchiverTaskMap() {
    if (_archiverTaskBox.isEmpty) {
      return null;
    }

    final map = <String, DownloadArchiverTaskInfo>{};

    for (final entry in _archiverTaskBox.toMap().entries) {
      final takInfo = DownloadArchiverTaskInfo.fromJson(
          jsonDecode(entry.value) as Map<String, dynamic>);
      logger.t('get archiverTask ${takInfo.toJson()}');
      if (takInfo.tag != null) {
        map[takInfo.tag!] = takInfo;
      }
    }

    return map;
  }

  GalleryCache? getCache(String gid) {
    final value = _galleryCacheBox.get(gid);

    if (value == null) {
      return null;
    }

    return GalleryCache.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  void saveCache(GalleryCache cache) {
    if (cache.gid != null) {
      _galleryCacheBox.put(cache.gid!, jsonEncode(cache));
    }
  }

  Profile get profile {
    final String? val = _configBox.get(profileKey);
    if (val == null) {
      return kDefProfile;
    }
    // logger.d('get profile $val');

    final Profile profileObj =
        Profile.fromJson(jsonDecode(val) as Map<String, dynamic>);

    // logger.d(' ${_profileObj.layoutConfig?.toJson()}');

    // final Profile _profile = kDefProfile.copyWith(
    //   user: _profileObj.user,
    //   ehConfig: _profileObj.ehConfig,
    //   lastLogin: _profileObj.lastLogin,
    //   locale: _profileObj.locale,
    //   theme: _profileObj.theme,
    //   searchText: _profileObj.searchText,
    //   localFav: _profileObj.localFav,
    //   enableAdvanceSearch: _profileObj.enableAdvanceSearch,
    //   advanceSearch: _profileObj.advanceSearch,
    //   dnsConfig: _profileObj.dnsConfig,
    //   downloadConfig: _profileObj.downloadConfig,
    //   webdav: _profileObj.webdav,
    //   autoLock: _profileObj.autoLock,
    //   favConfig: _profileObj.favConfig,
    //   customTabConfig: _profileObj.customTabConfig,
    //   layoutConfig: _profileObj.layoutConfig,
    // );
    // return _profile;

    return profileObj;
  }

  set profile(Profile? val) {
    _configBox.put(profileKey, jsonEncode(val));
  }
}
