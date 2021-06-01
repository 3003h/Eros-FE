/*
import 'dart:async';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/entity/tag_translat.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String dbname = 'eh_database.db';
const String tableTag = 'tag_translat';
const String columnNamespace = 'namespace';
const String columnKey = 'key';
const String columnName = 'name';
const String columnIntro = 'intro';
const String columnLinks = 'links';

final DataBaseUtil dbUtil = DataBaseUtil();

class DataBaseUtil {
  factory DataBaseUtil() => _instance;

  DataBaseUtil._();

  static final DataBaseUtil _instance = DataBaseUtil._();

  Future<Database> _getDataBase() async {
    // 获取数据库文件的存储路径
    // final String databasesPath = await getDatabasesPath();
    final String path = join(Global.appSupportPath, dbname);

    //根据数据库文件路径和数据库版本号创建数据库表
    final Future<Database> database = openDatabase(
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
  Future<void> insertTag(TagTranslatOld translat) async {
    final Database db = await _getDataBase();
    await db.insert(
      tableTag,
      translat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入
  Future<void> insertTagAll(List<TagTranslatOld> translats) async {
    final Database db = await _getDataBase();
    final Batch batch = db.batch();
    translats.forEach((TagTranslatOld translat) {
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
  Future<TagTranslatOld?> getTagTrans(String key,
      {String namespace = ''}) async {
    final Database db = await _getDataBase();

    final bool _isNameSpace = namespace != null && namespace.isNotEmpty;
    final String _where = _isNameSpace
        ? '$columnNamespace = ? and $columnKey = ?'
        : '$columnKey = ? ';
    final List<String> _args = _isNameSpace ? [namespace, key] : [key];

    final List<Map<String, dynamic>> maps = await db.query(
      tableTag,
      columns: [
        columnNamespace,
        columnKey,
        columnName,
        columnIntro,
        columnLinks
      ],
      where: _where,
      whereArgs: _args,
    );
    if (maps.isNotEmpty) {
      return TagTranslatOld.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TagTranslatOld>?> getTagTransFuzzy(String key,
      {int limit = 100}) async {
    final Database db = await _getDataBase();

    const String _where = '$columnKey like ? or $columnName like ?';
    // const String _where = "$columnKey like  ";

    final List<String> _args = <String>['%$key%', '%$key%'];

    final List<Map<String, dynamic>> maps = await db.query(
      tableTag,
      columns: [
        columnNamespace,
        columnKey,
        columnName,
        columnIntro,
        columnLinks
      ],
      where: _where,
      whereArgs: _args,
      limit: limit,
    );

    // final List<Map<String, dynamic>> mapsr = await db.rawQuery(
    //     "select * from $tableTag where key like'%$key%' or name like '%$key%' limit $limit");

    logger.d('${maps.length}');

    if (maps.isNotEmpty) {
      return List<TagTranslatOld>.from(maps
          .map((Map<String, dynamic> e) => TagTranslatOld.fromMap(e))
          .toList());
    }
    return null;
  }

  /// 获取翻译结果
  Future<String?> getTagTransStr(String key, {String namespace = ''}) async {
    final TagTranslatOld? tr =
        await getTagTrans(key.trim(), namespace: namespace.trim());
    return tr?.nameNotMD ?? key;
  }
}
*/
