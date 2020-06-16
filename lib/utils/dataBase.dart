import 'package:FEhViewer/fehviewer/model/tagTranslat.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

final String dbname = 'eh_database.db';
final String tableTag = 'tag_translat';
final String columnNamespace = 'namespace';
final String columnKey = 'key';
final String columnName = 'name';
final String columnIntro = 'intro';
final String columnLinks = 'links';

class DataBaseUtil {
  static DataBaseUtil _instance = new DataBaseUtil._();

  factory DataBaseUtil() => _instance;

  DataBaseUtil._();

  // 数据库初始化
  static Future<void> init() async {}

  static Future<Database> getDataBase() async {
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
  static void insertTag(TagTranslat translat) async {
    final Database db = await getDataBase();
    await db.insert(
      tableTag,
      translat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入
  static Future<void> insertTagAll(List<TagTranslat> translats) async {
    final Database db = await getDataBase();
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

  static Future<TagTranslat> getTagTrans(String key, {String namespace}) async {
    final Database db = await getDataBase();

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

  static Future<String> getTagTransStr(String key, {String namespace}) async {
    var tr = await getTagTrans(key, namespace: namespace);
    return tr?.name;
  }

}
