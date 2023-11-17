import 'dart:async';

import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/store/mysql/const.dart';
import 'package:mysql_client/mysql_client.dart';

import 'migration.dart';

class FeMySql {
  // 工厂构造函数，用于创建单例实例
  factory FeMySql({
    MySQLConnectionInfo? connectionInfo,
    bool newConnection = false,
  }) {
    return _instance.._init(connectionInfo, newConnection);
  }
  // 私有构造方法，确保只能在类内部创建实例
  FeMySql._();

  // 单例实例
  static final FeMySql _instance = FeMySql._();

  bool get isInit => _initCompleter?.isCompleted ?? false;

  Completer? _initCompleter;

  late MySQLConnection _conn;
  final List<Migration> migrations = [];

  // 内部初始化方法
  Future<void> _init(
      MySQLConnectionInfo? connectionInfo, bool newConnection) async {
    if (connectionInfo == null) {
      return;
    }

    if (isInit && _conn.connected && !newConnection) {
      return;
    }

    _initCompleter = Completer();

    _conn = await MySQLConnection.createConnection(
      host: connectionInfo.host,
      port: connectionInfo.port,
      userName: connectionInfo.userName,
      password: connectionInfo.password,
      databaseName: connectionInfo.databaseName,
    );

    try {
      await _conn.connect();
      logger.d('mysql connect success');
      await initTables();
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }

    _initCompleter?.complete();
  }

  Future<bool> testConnect() async {
    await _initCompleter?.future;
    final result = await _conn.execute('SELECT 1');
    result.rows.forEach((element) {
      logger.d(element.assoc());
    });
    return result.rows.isNotEmpty;
  }

  Future<void> close() async {
    _initCompleter = Completer();
    await _conn.close();
  }

  Future<void> reConnect(MySQLConnectionInfo? connectionInfo) async {
    await close();
    await _init(connectionInfo, true);
  }

  Future<void> connect(MySQLConnectionInfo? connectionInfo) async {
    if (_conn.connected) {
      return;
    }
    await _init(connectionInfo, true);
  }

  FeMySql addMigrations(List<Migration> migrations) {
    this.migrations.addAll(migrations);
    return this;
  }

  Future<void> migrate() async {
    logger.d('migrate');

    final version = await getVersion();
    logger.d('version $version');
    if (version == null) {
      logger.d('version is null, insertVersion');
      await insertVersion();
      return;
    }

    const lastVersion = kVersion;

    if (version == lastVersion) {
      return;
    }

    for (final migration in migrations) {
      if (version < migration.targetVersion) {
        await migration.execute(_conn);
        await setVersion(migration.targetVersion);
      }
    }
  }

  Future<void> initTables() async {
    // mysql table info :key value
    await _conn.execute('''
      CREATE TABLE IF NOT EXISTS `fe_info` (
        `key_name` VARCHAR(255) NOT NULL,
        `value` VARCHAR(255) NOT NULL,
        PRIMARY KEY (`key_name`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ''');

    // mysql table fe_read_progress :gid page last_view_time
    await _conn.execute('''
      CREATE TABLE IF NOT EXISTS `fe_read_progress` (
        `gid` VARCHAR(30) NOT NULL,
        `page` INT(10) NOT NULL,
        `time` BIGINT(15) NOT NULL,
        PRIMARY KEY (`gid`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ''');

    // mysql table fe_history :gid time json
    await _conn.execute('''
      CREATE TABLE IF NOT EXISTS `fe_history` (
        `gid` VARCHAR(30) NOT NULL,
        `time` BIGINT(15) NOT NULL,
        `json` TEXT NOT NULL,
        PRIMARY KEY (`gid`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ''');

    await migrate();
  }

  Future<void> insertVersion() async {
    const version = kVersion;
    await _conn.execute('''
      INSERT INTO fe_info (key_name, value) VALUES ('version', $version)
    ''');
  }

  Future<int?> getVersion() async {
    logger.d('getVersion');
    final IResultSet result = await _conn.execute(
        'SELECT value FROM fe_info WHERE key_name= :key_name',
        {'key_name': 'version'});
    if (result.rows.isEmpty) {
      return null;
    }

    final version = result.rows.first.colAt(0);
    if (version == null) {
      return null;
    }
    logger.d('version $version');

    return int.tryParse(version);
  }

  Future<void> setVersion(int targetVersion) async {
    await _conn.execute('''
      UPDATE fe_info SET value = :value WHERE key_name = :key_name'
    ''', {
      'key_name': 'version',
      'value': targetVersion,
    });
  }

  // ReadProgress
  Future<void> insertReadProgress(String gid, int? page, int? time) async {
    await _conn.execute('''
      INSERT INTO fe_read_progress (gid, page, time) VALUES (:gid, :page, :time) ON DUPLICATE KEY UPDATE page = :page, time = :time
    ''', {
      'gid': gid,
      'page': page,
      'time': time,
    });
  }

  Future<void> updateReadProgress(String gid, int page, int time) async {
    await _conn.execute('''
      UPDATE fe_read_progress SET page = :page, time = :time WHERE gid = :gid
    ''', {
      'gid': gid,
      'page': page,
      'time': time,
    });
  }

  Future<void> deleteReadProgress(String gid) async {
    await _conn.execute('''
      DELETE FROM fe_read_progress WHERE gid = :gid
    ''', {
      'gid': gid,
    });
  }

  Future<({String gid, int page, int time})?> getReadProgress(
      String gid) async {
    final IResultSet result = await _conn.execute(
        'SELECT gid, page, time FROM fe_read_progress WHERE gid= :gid',
        {'gid': gid});
    if (result.rows.isEmpty) {
      return null;
    }

    final row = result.rows.first.typedAssoc();

    logger.d('read Process row $row');

    return (
      gid: row['gid'] as String,
      page: row['page'] as int,
      time: row['time'] as int,
    );
  }

  // History
  Future<void> insertHistory(String gid, int? time, String? json) async {
    await _conn.execute('''
      INSERT INTO fe_history (gid, time, json) VALUES (:gid, :time, :json) ON DUPLICATE KEY UPDATE time = :time, json = :json
    ''', {
      'gid': gid,
      'time': time,
      'json': json,
    });
  }

  Future<void> updateHistory(String gid, int time, String json) async {
    await _conn.execute('''
      UPDATE fe_history SET time = :time, json = :json WHERE gid = :gid
    ''', {
      'gid': gid,
      'time': time,
      'json': json,
    });
  }

  Future<void> deleteHistory(String gid) async {
    await _conn.execute('''
      DELETE FROM fe_history WHERE gid = :gid
    ''', {
      'gid': gid,
    });
  }

  Future<({String gid, int time, String json})?> getHistory(String gid) async {
    final IResultSet result = await _conn.execute(
        'SELECT gid, time, json FROM fe_history WHERE gid= :gid', {'gid': gid});
    if (result.rows.isEmpty) {
      return null;
    }

    final row = result.rows.first.typedAssoc();

    logger.d('history row $row');

    return (
      gid: row['gid'] as String? ?? '',
      time: row['time'] as int? ?? 0,
      json: row['json'] as String? ?? '',
    );
  }

  Future<int> getHistoryTime(String gid) async {
    final IResultSet result = await _conn
        .execute('SELECT time FROM fe_history WHERE gid= :gid', {'gid': gid});
    if (result.rows.isEmpty) {
      return 0;
    }

    final row = result.rows.first.typedAssoc();

    logger.d('history row $row');

    return row['time'] as int? ?? 0;
  }

  Future<List<({String gid, int time})>> getHistoryTimeList() async {
    final IResultSet result = await _conn
        .execute('SELECT gid, time FROM fe_history ORDER BY time DESC');
    if (result.rows.isEmpty) {
      return [];
    }

    final list = <({String gid, int time})>[];
    result.rows.forEach((element) {
      final row = element.typedAssoc();
      list.add(
        (
          gid: row['gid'] as String? ?? '',
          time: row['time'] as int? ?? 0,
        ),
      );
    });

    return list;
  }

  Future<List<({String gid, int time, String json})>> getHistoryList(
    List<String> subList,
  ) async {
    final _list = <({String gid, int time, String json})>[];

    final _splitList = EHUtils.splitList(subList, 50);
    for (final _subSubList in _splitList) {
      logger.t('_subSubList $_subSubList');

      final result = await _conn.execute(
          'SELECT gid, time, json FROM fe_history WHERE gid IN (${_subSubList.join(',')})');

      final rows = result.rows;
      logger.d('rows ${rows.length}');

      if (rows.isNotEmpty) {
        rows.forEach((element) {
          final row = element.typedAssoc();
          _list.add(
            (
              gid: row['gid'] as String? ?? '',
              time: row['time'] as int? ?? 0,
              json: row['json'] as String? ?? '',
            ),
          );
        });
      }
    }

    return _list;
  }
}
