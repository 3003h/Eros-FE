import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:dio/dio.dart';
import 'package:FEhViewer/http/dio_util.dart';
import 'package:flutter/cupertino.dart';

class EhUserManager {
  static Future<dynamic> signIn(String username, String passwd) async {
    HttpManager httpManager =
        HttpManager.getInstance("https://forums.e-hentai.org");
    const url = "/index.php?act=Login&CODE=01";
    const referer = "https://forums.e-hentai.org/index.php?act=Login&CODE=00";
    const origin = "https://forums.e-hentai.org";

    FormData formData = new FormData.fromMap({
      "UserName": username,
      "PassWord": passwd,
      "submit": "Log me in",
      "temporary_https": "off",
      "CookieDate": "1",
    });

    Options options = Options(headers: {"Referer": referer, "Origin": origin});

    Response rult =
        await httpManager.postForm(url, data: formData, options: options);

    // TODO 登录异常处理

    var setcookie = rult.headers['set-cookie'];

    var cookieMap = parseSetCookieString(setcookie);

    var cookie = {
      "ipb_member_id": cookieMap["ipb_member_id"],
      "ipb_pass_hash": cookieMap["ipb_pass_hash"],
      "yay": "louder"
    };

    var cookieStr = getCookieStringFromMap(cookie);
    debugPrint(cookieStr);

    StorageUtil().setString(COOKIE, cookieStr);

    debugPrint('${StorageUtil().getString(COOKIE)}');

    return rult;
  }

  /// 处理SetCookie 转为map
  static parseSetCookieString(List setCookieStrings) {
    var cookie = {};
    RegExp regExp = new RegExp(r"^([^;=]+)=([^;]+);");
    setCookieStrings.forEach((setCookieString) {
      var found = regExp.firstMatch(setCookieString);
//      debugPrint('${found.group(1)}   ${found.group(2)}');
      cookie[found.group(1)] = found.group(2);
    });

//    debugPrint('in   $cookie');
    return cookie;
  }

  static getCookieStringFromMap(Map cookie) {
    var texts = [];
    cookie.forEach((key, value) {
      texts.add('$key=$value');
    });
    return texts.join("; ");
  }
}
