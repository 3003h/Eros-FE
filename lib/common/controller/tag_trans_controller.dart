import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/store/floor/dao/tag_translat_dao.dart';
import 'package:fehviewer/store/floor/database.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:fehviewer/utils/dio_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../global.dart';

const String kUrl = '/repos/EhTagTranslation/Database/releases/latest';
const int kConnectTimeout = 10000;
const int kReceiveTimeout = 30000;

class TagTransController extends GetxController {
  final EhConfigService ehConfigService = Get.find();

  final HttpManager _httpManager =
      HttpManager.getInstance(baseUrl: 'https://api.github.com', cache: false);

  late String _dbUrl;
  late String _remoteVer;

  static final String _dbPath =
      path.join(Global.appSupportPath, 'gallery_task.db');

  static Future<EhDatabase> _getDatabase() async {
    return await $FloorEhDatabase.databaseBuilder(_dbPath).build();
  }

  Future<TagTranslatDao> _getTagTranslatDao() async {
    return (await _getDatabase()).tagTranslatDao;
  }

  /// 检查更新
  Future<void> checkUpdate() async {
    final String urlJsonString = await _httpManager.get(kUrl) ?? '';
    final dynamic _urlJson = jsonDecode(urlJsonString);
    // 获取发布时间 作为远程版本号
    final String _remoteVer =
        (_urlJson != null ? _urlJson['published_at']?.trim() : '') as String;

    // 获取当前本地版本
    final String localVer = ehConfigService.tagTranslatVer.value ?? '';

    if (_remoteVer == localVer) {
      return;
    }

    final List assList = _urlJson['assets'];
    final Map<String, String> assMap = <String, String>{};
    for (final dynamic assets in assList) {
      assMap[assets['name']] = assets['browser_download_url'];
    }
    _dbUrl = assMap['db.raw.json'] ?? '';

    logger.v(_dbUrl);
  }

  /// 获取数据
  Future<List> _fetch() async {
    if (_dbUrl == null) {
      return [];
    }

    final HttpManager httpDB = HttpManager.getInstance();
    final Options options = Options(receiveTimeout: kReceiveTimeout);
    final String dbJson = await httpDB.get(_dbUrl, options: options) ?? '{}';

    final dbdataMap = jsonDecode(dbJson);
    final List listData = dbdataMap['data'] as List;

    return listData;
  }

  /// 更新数据库数据
  Future<void> updateDB() async {
    final TagTranslatDao tagTranslatDao = await _getTagTranslatDao();

    List listData = await _fetch();
    if (listData.isEmpty) {
      return;
    }

    final List<TagTranslat> TagTranslats = listData.map((e) {
      final String _namespace = e['namespace'] as String;
      final Map _map = e['data'] as Map;
      return TagTranslat(
        namespace: _namespace,
        key: _map['key'] ?? '',
        name: _map['name'] ?? '',
        intro: _map['intro'] ?? '',
        links: _map['links'] ?? '',
      );
    }).toList();

    tagTranslatDao.insertAllTagTranslats(TagTranslats);

    ehConfigService.tagTranslatVer.value = _remoteVer;
  }

  /// 获取翻译结果
  Future<String?> _getTagTransStr(String key, {String namespace = ''}) async {
    final TagTranslatDao tagTranslatDao = await _getTagTranslatDao();
    final TagTranslat? tr =
        await tagTranslatDao.findTagTranslatByKey(key.trim(), namespace.trim());
    return tr?.name ?? '';
  }

  Future<String?> getTranTagWithNameSpase(String tag,
      {String nameSpase = ''}) async {
    if (tag.contains(':')) {
      final RegExp rpfx = RegExp(r'(\w+):"?([^\$]+)\$?"?');
      final RegExpMatch? rult = rpfx.firstMatch(tag.toLowerCase());
      String _nameSpase = rult?.group(1) ?? '';
      if (_nameSpase.length == 1) {
        _nameSpase = EHConst.prefixToNameSpaceMap[_nameSpase] ?? _nameSpase;
      }

      final String _tag = rult?.group(2) ?? '';
      final String _nameSpaseTran =
          EHConst.translateTagType[_nameSpase] ?? _nameSpase;
      final String _transTag =
          await _getTagTransStr(_tag, namespace: _nameSpase) ?? _tag;

      return '$_nameSpaseTran:$_transTag';
    } else {
      return await _getTagTransStr(tag.toLowerCase(), namespace: nameSpase);
    }
  }

  Future<String?> getTranTag(String tag, {String nameSpase = ''}) async {
    if (tag.contains(':')) {
      final RegExp rpfx = RegExp(r'(\w):(.+)');
      final RegExpMatch? rult = rpfx.firstMatch(tag.toLowerCase());
      final String pfx = rult?.group(1) ?? '';
      final String _nameSpase = EHConst.prefixToNameSpaceMap[pfx] as String;
      final String _tag = rult?.group(2) ?? '';
      final String? _transTag =
          await _getTagTransStr(_tag, namespace: _nameSpase);

      return _transTag != null ? '$pfx:$_transTag' : tag;
    } else {
      return await _getTagTransStr(tag.toLowerCase(), namespace: nameSpase);
    }
  }

  Future<List<TagTranslat>> getTagTranslatesLike(
      {String text = '', int limit = 100}) async {
    final TagTranslatDao tagTranslatDao = await _getTagTranslatDao();

    final List<TagTranslat> _translates =
        await tagTranslatDao.findTagTranslatsWithLike(text, text, limit);
    return _translates;
  }
}
