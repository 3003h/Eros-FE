import 'dart:convert';
import 'package:FEhViewer/common/global.dart';
import 'package:dio/dio.dart';
import 'package:FEhViewer/models/entity/tag_translat.dart';
import 'package:FEhViewer/http/dio_util.dart';
import 'package:FEhViewer/utils/dataBase.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/storages.dart';

final int connectTimeout = 10000;
final int receiveTimeout = 30000;

class EhTagDatabase {
  ///tag翻译
  static Future<String> generateTagTranslat() async {
    HttpManager httpManager = HttpManager.getInstance("https://api.github.com");

    const url = "/repos/EhTagTranslation/Database/releases/latest";

    var urlJson = await httpManager.get(url);

    // 获取发布时间 作为版本号
    var remoteVer = "";
    remoteVer = urlJson != null ? urlJson["published_at"] : '';
    Global.loggerNoStack.v("remoteVer $remoteVer");

    var localVer = StorageUtil().getString(TAG_TRANSLAT_VER);
    Global.loggerNoStack.v("localVer $localVer");

    // 测试
//    localVer = 'aaaaaaa';

    StorageUtil().setString(TAG_TRANSLAT_VER, remoteVer);

    var dbJson = jsonEncode(StorageUtil().getJSON(TAG_TRANSLAT));

    if (dbJson == null ||
        dbJson.isEmpty ||
        dbJson == "null" ||
        remoteVer != localVer) {
      Global.loggerNoStack.v("TagTranslat更新");
      List assList = urlJson["assets"];

      Map assMap = new Map();
      assList.forEach((assets) {
        assMap[assets["name"]] = assets["browser_download_url"];
      });
      var dbUrl = assMap["db.text.json"];

      Global.loggerNoStack.v(dbUrl);

      HttpManager httpDB = HttpManager.getInstance();

      Options options = Options(receiveTimeout: receiveTimeout);

      dbJson = await httpDB.get(dbUrl, options: options);
      if (dbJson != null) {
        var dataAll = jsonDecode(dbJson.toString());
        var listDataP = dataAll["data"];
        StorageUtil().setJSON(TAG_TRANSLAT, jsonEncode(listDataP));

        await tagSaveToDB(listDataP);
      }
      Global.loggerNoStack.v("tag翻译更新完成");
    } else {
      Global.loggerNoStack.v("tag为最新数据 不需更新");
    }

    return remoteVer;
  }

  /// 保存到数据库
  static Future<void> tagSaveToDB(List listDataP) async {
    List<TagTranslat> tags = [];

    listDataP.forEach((objC) {
      Global.loggerNoStack.v('${objC['namespace']}  ${objC['count']}');
      final _namespace = objC['namespace'];
      Map mapC = objC['data'];
      mapC.forEach((key, value) {
        final _key = key;
        final _name = value['name'] ?? '';
        final _intro = value['intro'] ?? '';
        final _links = value['links'] ?? '';

        tags.add(
            TagTranslat(_namespace, _key, _name, intro: _intro, links: _links));
      });
    });

    await DataBaseUtil().insertTagAll(tags);

    Global.loggerNoStack.v('tag中文翻译数量 ${tags.length}');
  }

  static Future<String> getTranTag(String tag) async {
    if (tag.contains(':')) {
//      debugPrint('$tag');
      RegExp rpfx = new RegExp(r"(\w:)(.+)");
      final rult = rpfx.firstMatch(tag);
      final pfx = rult.group(1) ?? '';
      final _nameSpase = EHConst.prefixToNameSpaceMap[pfx];
      final _tag = rult.group(2) ?? '';
      final _transTag =
          await DataBaseUtil().getTagTransStr(_tag, namespace: _nameSpase);

      return _transTag != null ? '$pfx$_transTag' : tag;
    } else {
      return await DataBaseUtil().getTagTransStr(tag);
    }
  }
}
