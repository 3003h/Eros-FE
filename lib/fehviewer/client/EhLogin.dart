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

    Options options = Options(headers: {
      "Referer": referer,
      "Origin": origin
    });

    var rult = await httpManager.postForm(url, data: formData, options: options);

    debugPrint('$rult');

    return rult;
  }
}
