import 'dart:convert';

import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/store/mysql/mysql.dart';
import 'package:get/get.dart';

class MysqlController extends GetxController {
  // 是否同步历史记录
  final _syncHistory = false.obs;
  bool get syncHistory => _syncHistory.value;
  set syncHistory(bool val) => _syncHistory.value = val;

  MySQLConfig get mysqlConfig =>
      Global.profile.mysqlConfig ?? const MySQLConfig(isValidAccount: false);
  set mysqlConfig(MySQLConfig val) {
    Global.profile = Global.profile.copyWith(
      mysqlConfig: val,
    );
    Global.saveProfile();
  }

  // 是否同步画廊阅读进度
  final _syncReadProgress = false.obs;
  bool get syncReadProgress => _syncReadProgress.value;
  set syncReadProgress(bool val) => _syncReadProgress.value = val;

  final _syncGroupProfile = false.obs;
  bool get syncGroupProfile => _syncGroupProfile.value;
  set syncGroupProfile(bool val) => _syncGroupProfile.value = val;

  final _syncQuickSearch = false.obs;
  bool get syncQuickSearch => _syncQuickSearch.value;
  set syncQuickSearch(bool val) => _syncQuickSearch.value = val;

  final _isValidAccount = false.obs;
  bool get isValidAccount => _isValidAccount.value;
  set isValidAccount(bool val) => _isValidAccount.value = val;

  final _databaseName = ''.obs;
  String get databaseName => _databaseName.value;
  set databaseName(String val) => _databaseName.value = val;

  final _dataBaseHost = ''.obs;
  String get dataBaseHost => _dataBaseHost.value;
  set dataBaseHost(String val) => _dataBaseHost.value = val;

  MySQLConnectionInfo? _connectionInfo;
  MySQLConnectionInfo? get connectionInfo =>
      _connectionInfo ?? mysqlConfig.mysqlConnectionInfo;
  set connectionInfo(MySQLConnectionInfo? val) {
    _connectionInfo = val;
    if (val != null) {
      mysqlConfig = mysqlConfig.copyWith(
        mysqlConnectionInfo: val,
      );
    }
  }

  String get connectionText =>
      '${connectionInfo?.userName}@${connectionInfo?.host}:'
      '${connectionInfo?.port}/${connectionInfo?.databaseName}';

  FeMySql? feMySql;

  @override
  void onInit() {
    super.onInit();
    if (connectionInfo != null && (mysqlConfig.isValidAccount ?? false)) {
      feMySql = FeMySql(connectionInfo: connectionInfo);
    }

    isValidAccount = mysqlConfig.isValidAccount ?? false;
    ever(
        _isValidAccount,
        (val) => mysqlConfig = mysqlConfig.copyWith(
              isValidAccount: val,
            ));

    syncReadProgress = mysqlConfig.syncReadProgress ?? false;
    ever(
        _syncReadProgress,
        (val) => mysqlConfig = mysqlConfig.copyWith(
              syncReadProgress: val,
            ));

    syncHistory = mysqlConfig.syncHistory ?? false;
    ever(
        _syncHistory,
        (val) => mysqlConfig = mysqlConfig.copyWith(
              syncHistory: val,
            ));

    syncGroupProfile = mysqlConfig.syncGroupProfile ?? false;
    ever(
        _syncGroupProfile,
        (val) => mysqlConfig = mysqlConfig.copyWith(
              syncGroupProfile: val,
            ));

    syncQuickSearch = mysqlConfig.syncQuickSearch ?? false;
    ever(
        _syncQuickSearch,
        (val) => mysqlConfig = mysqlConfig.copyWith(
              syncQuickSearch: val,
            ));
  }

  Future<bool?> loginMySQL({
    required MySQLConnectionInfo connectionInfo,
  }) async {
    await 1.delay();
    logger.d('loginMySQL ${connectionInfo.toJson()}');

    this.connectionInfo = connectionInfo;
    feMySql = FeMySql(connectionInfo: connectionInfo);

    try {
      final result = await feMySql?.testConnect();
      logger.d('loginMySQL $result');
      if (result == true) {
        mysqlConfig = mysqlConfig.copyWith(
          isValidAccount: true,
          mysqlConnectionInfo: connectionInfo,
        );
        isValidAccount = true;
        return true;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      return false;
    }

    return false;
  }

  // 上传进度
  Future<void> uploadRead(GalleryCache read) async {
    logger.d('mysql uploadRead ${read.toJson()}');
    final gid = read.gid;

    if (gid == null || gid.isEmpty) {
      logger.e('uploadRead gid is null');
      return;
    }
    final time = read.time;
    final page = read.lastIndex;
    try {
      await feMySql?.insertReadProgress(gid, page, time);
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }

  Future<void> test() async {
    // feMySql?.insertVersion();
    // feMySql?.getVersion();
    feMySql?.testInit(connectionInfo);
  }

  Future<GalleryCache?> downloadRead(String gid) async {
    logger.d('qryRead $gid');
    if (gid.isEmpty) {
      logger.e('gid is empty');
      return null;
    }
    try {
      final result = await feMySql?.getReadProgress(gid);
      logger.d('qryRead $result');
      if (result != null) {
        return GalleryCache(
            gid: result.gid, lastIndex: result.page, time: result.time);
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
    return null;
  }

  Future<void> uploadHistory(GalleryProvider his) async {
    final _his = his.copyWith(
      galleryComment: [],
      galleryImages: [],
      tagGroup: [],
    );
    final _gid = _his.gid;

    if (_gid == null || _gid.isEmpty) {
      logger.e('uploadHistory gid is null');
      return;
    }

    logger.d('uploadHistory ${_his.gid}');

    final _text = jsonEncode(_his);
    final _time = _his.lastViewTime;

    try {
      await feMySql?.insertHistory(_gid, _time, _text);
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }

  Future<int?> getHistoryTime(String gid) async {
    logger.d('getHistoryTime $gid');
    if (gid.isEmpty) {
      logger.e('gid is empty');
      return null;
    }
    try {
      final result = await feMySql?.getHistoryTime(gid);
      logger.d('getHistoryTime $result');
      return result;
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
    return null;
  }

  Future<GalleryProvider?> downloadHistory(String gid) async {
    logger.d('downloadHistory $gid');
    if (gid.isEmpty) {
      logger.e('gid is empty');
      return null;
    }
    try {
      final result = await feMySql?.getHistory(gid);
      logger.d('downloadHistory $result');
      if (result != null) {
        return GalleryProvider.fromJson(jsonDecode(result.json));
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
    return null;
  }

  Future<List<GalleryProvider?>> downloadHistoryList(
      List<String?> gidList) async {
    // 50 个一组
    final _gidList = gidList.whereType<String>().toList();
    final _list = <GalleryProvider?>[];
    while (_gidList.isNotEmpty) {
      final _subList = _gidList.sublist(0, 50);
      _gidList.removeRange(0, _subList.length);
      final _result = await feMySql?.getHistoryList(_subList);
      logger.d('downloadHistoryList $_result');
      if (_result != null) {
        _list.addAll(
            _result.map((e) => GalleryProvider.fromJson(jsonDecode(e.json))));
      }
    }
    return _list;
  }

  Future<List<HistoryIndexGid>> getHistoryList() async {
    logger.d('getHistoryList');
    try {
      final result = await feMySql?.getHistoryTimeList();
      logger.d('getHistoryList $result');
      if (result != null) {
        return result.map((e) => HistoryIndexGid(g: e.gid, t: e.time)).toList();
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
    return [];
  }
}
