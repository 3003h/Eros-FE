import 'package:mysql_client/mysql_client.dart';

import 'connection_info.dart';
import 'migration.dart';

class FeMySql {
  // 工厂构造函数，用于创建单例实例
  factory FeMySql({ConnectionInfo? connectionInfo}) {
    return _instance.._init(connectionInfo);
  }
  // 私有构造方法，确保只能在类内部创建实例
  FeMySql._();

  // 单例实例
  static final FeMySql _instance = FeMySql._();

  late MySQLConnection _conn;
  List<Migration>? migrations;

  // 内部初始化方法
  Future<void> _init(ConnectionInfo? connectionInfo) async {
    _conn = await MySQLConnection.createConnection(
      host: connectionInfo!.host,
      port: connectionInfo.port,
      userName: connectionInfo.userName,
      password: connectionInfo.password,
      databaseName: connectionInfo.databaseName,
    );
    await _conn.connect();
  }

  FeMySql addMigrations(List<Migration> migrations) {
    this.migrations = migrations;
    return this;
  }

  Future<void> migrate() async {
    if (migrations == null) {
      return;
    }

    final version = await getVersion() ?? 0;
    final lastVersion = migrations!.last.targetVersion;

    if (version == lastVersion) {
      return;
    }

    for (final migration in migrations!) {
      if (version < migration.targetVersion) {
        await migration.execute(_conn);
        await setVersion(migration.targetVersion);
      }
    }
  }

  Future<int?> getVersion() async {
    final result = await _conn.execute('SELECT version FROM version');
    if (result.isEmpty) {
      return null;
    }

    return result.first as int;
  }

  Future<void> setVersion(int targetVersion) async {
    await _conn.execute('UPDATE version SET version = $targetVersion');
  }
}
