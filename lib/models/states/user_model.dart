import 'package:flutter/cupertino.dart';

import '../user.dart';
import 'base.dart';

class UserModel extends ProfileChangeNotifier {
  User get user => profile.user;

  // APP是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => user?.username != null;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
  set user(User user) {
    debugPrint('set user  $user');
    if (user?.username != super.profile.user?.username) {
      profile.lastLogin = profile.user?.username;
      profile.user = user;
      notifyListeners();
    }
  }
}
