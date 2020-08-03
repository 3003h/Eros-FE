import 'package:FEhViewer/common/global.dart';

import '../profile.dart';
import '../user.dart';
import 'base.dart';

class UserModel extends ProfileChangeNotifier {
  Profile get _profile => Global.profile;
  User get user => _profile.user;

  // APP是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => user?.username != null;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
  set user(User user) {
    if (user?.username != _profile.user?.username) {
      _profile.lastLogin = _profile.user?.username;
      _profile.user = user;
      notifyListeners();
    }
  }
}
