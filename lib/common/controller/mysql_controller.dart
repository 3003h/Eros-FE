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

  Future<GalleryCache?> qryRead(String gid) async {
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
}
