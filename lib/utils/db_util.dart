import 'dart:async';

import 'package:FEhViewer/models/entity/tag_translat.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String dbname = 'eh_database.db';
final String tableTag = 'tag_translat';
final String columnNamespace = 'namespace';
final String columnKey = 'key';
final String columnName = 'name';
final String columnIntro = 'intro';
final String columnLinks = 'links';

class DataBaseUtil {
  static DataBaseUtil _instance = DataBaseUtil._();

  factory DataBaseUtil() => _instance;

  DataBaseUtil._();

  Future<Database> _getDataBase() async {
    // 获取数据库文件的存储路径
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbname);

    //根据数据库文件路径和数据库版本号创建数据库表
    var database = openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) {
        return db.execute(
          '''
          CREATE TABLE $tableTag(
          $columnNamespace TEXT, 
          $columnKey TEXT, 
          $columnName TEXT, 
          $columnIntro TEXT, 
          $columnLinks TEXT,
          PRIMARY KEY($columnNamespace, $columnKey))
          ''',
        );
      },
    );

    return database;
  }

  // 单条插入
  Future<void> insertTag(TagTranslat translat) async {
    final Database db = await this._getDataBase();
    await db.insert(
      tableTag,
      translat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入
  Future<void> insertTagAll(List<TagTranslat> translats) async {
    final Database db = await this._getDataBase();
    var batch = db.batch();
    translats.forEach((translat) {
      batch.insert(
        tableTag,
        translat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true, continueOnError: true);
//    var rult = await batch.commit();
//    debugPrint('rult $rult');
  }

  /// 获取翻译对象
  Future<TagTranslat> getTagTrans(String key, {String namespace}) async {
    final Database db = await this._getDataBase();

    bool _isNameSpace = namespace != null && namespace.isNotEmpty;
    var _where = _isNameSpace
        ? '$columnNamespace = ? and $columnKey = ?'
        : '$columnKey = ? ';
    var _args = _isNameSpace ? [namespace, key] : [key];

//    debugPrint('$_where  $_args');

    List<Map> maps = await db.query(tableTag,
        columns: [
          columnNamespace,
          columnKey,
          columnName,
          columnIntro,
          columnLinks
        ],
        where: _where,
        whereArgs: _args);
//    debugPrint('qryMaps $maps');
    if (maps.length > 0) {
      return TagTranslat.fromMap(maps.first);
    }
    return null;
  }

  /// 获取翻译结果
  Future<String> getTagTransStr(String key, {String namespace}) async {
    var tr = await getTagTrans(key.trim(), namespace: namespace.trim());
    return tr?.name;
  }
}
