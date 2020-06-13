import 'package:FEhViewer/http/dio_util.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/storages.dart';

import 'dart:convert';

import 'package:flutter/cupertino.dart';

// 翻译
String translateTagType(eng) {
  const d = {
    'artist': "作者",
    'female': "女性",
    'male': "男性",
    'parody': "原作",
    'character': "角色",
    'group': "团队",
    'language': "语言",
    'reclass': "归类",
    'misc': "杂项"
  };
  return d[eng];
}

// 标签颜色
getNameAndColor(name) {
  const d = {
    "misc": {"string": "Misc", "color": "#777777"},
    "doujinshi": {"string": "Doujinshi", "color": "#9E2720"},
    "manga": {"string": "Manga", "color": "#DB6C24"},
    "artist cg": {"string": "Artist CG", "color": "#D38F1D"},
    "game cg": {"string": "Game CG", "color": "#617C63"},
    "image set": {"string": "Image Set", "color": "#325CA2"},
    "cosplay": {"string": "Cosplay", "color": "#6A32A2"},
    "asian porn": {"string": "Asian Porn", "color": "#A23282"},
    "non-h": {"string": "Non-H", "color": "#5FA9CF"},
    "western": {"string": "Western", "color": "#AB9F60"}
  };
  return d[name.toLowerCase()];
}

class API {
  /*
   * tag翻译
   */
  static Future<String> generateTagTranslat() async {
    HttpManager httpManager = HttpManager.getInstance("https://api.github.com");

    const url = "/repos/EhTagTranslation/Database/releases/latest";

    var urlJson = await httpManager.get(url);

    // 获取发布时间 作为版本号
    var curVer = "";
    curVer = urlJson["published_at"];
    print(curVer);

    var oriVer = StorageUtil().getString(TAG_TRANSLAT_VER);
    print(oriVer);

    StorageUtil().setString(TAG_TRANSLAT_VER, curVer);

    var dbJson = jsonEncode(StorageUtil().getJSON(TAG_TRANSLAT));

    if (dbJson == null ||
        dbJson.isEmpty ||
        dbJson == "null" ||
        curVer != oriVer) {
      print("TagTranslat更新");
      List assList = urlJson["assets"];

      Map assMap = new Map();
      assList.forEach((assets) {
        assMap[assets["name"]] = assets["browser_download_url"];
      });
      var dbUrl = assMap["db.text.json"];

      print(dbUrl);

      HttpManager httpDB = HttpManager.getInstance();
      dbJson = await httpDB.get(dbUrl);
      if (dbJson != null) {
        var data = jsonDecode(dbJson.toString());
        data = data["data"];
        StorageUtil().setJSON(TAG_TRANSLAT, jsonEncode(data));
      }
      print("更新完成");
    } else {
      debugPrint("不需更新");
    }

    return curVer;
  }
}
