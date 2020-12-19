import 'package:fehviewer/common/global.dart';
import 'package:flutter/cupertino.dart';

class ProfileChangeNotifier with ChangeNotifier {
  @override
  void notifyListeners() {
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners(); //通知依赖的Widget更新
  }
}
