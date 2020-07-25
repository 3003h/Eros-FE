import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class EHUtils {
  /// list 分割
  static List<List<T>> splitList<T>(List<T> list, int len) {
    if (len <= 1) {
      return [list];
    }

    List<List<T>> result = List();
    int index = 1;

    while (true) {
      if (index * len < list.length) {
        List<T> temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      List<T> temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }
}

class Api {
  //改为使用 PersistCookieJar，在文档中有介绍，PersistCookieJar将cookie保留在文件中，
  // 因此，如果应用程序退出，则cookie始终存在，除非显式调用delete
  static PersistCookieJar _cookieJar;

  static Future<PersistCookieJar> get cookieJar async {
    // print(_cookieJar);
    if (_cookieJar == null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      print('获取的文件系统目录 appDocPath： ' + appDocPath);
      _cookieJar = new PersistCookieJar(dir: appDocPath);
    }
    return _cookieJar;
  }
}
