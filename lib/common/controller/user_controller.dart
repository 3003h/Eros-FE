import 'package:eros_fe/common/controller/base_controller.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/tab/controller/favorite/favorite_tabbar_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class UserController extends ProfileController {
  bool get isLogin =>
      (user.value.memberId?.isNotEmpty ?? false) &&
      (user.value.passHash?.isNotEmpty ?? false);

  // bool get isLogin => user.value.username?.isNotEmpty ?? false;

  Rx<User> user = kDefUser.obs;

  final EhSettingService _ehSettingService = Get.find();

  void _logOut() {
    user(kDefUser);
    final WebviewCookieManager cookieManager = WebviewCookieManager();
    cookieManager.clearCookies();
  }

  @override
  void onInit() {
    super.onInit();
    user(Global.profile.user);
    // logger.d('${user.toJson()}');
    everProfile<User>(
      user,
      (User value) {
        Global.profile = Global.profile.copyWith(user: value);
        if (Get.isRegistered<FavoriteTabberController>()) {
          logger.d('everProfile User  => update FavoriteTabberController');
          Get.find<FavoriteTabberController>().onInit();
          Get.find<FavoriteTabberController>().update();
        }
      },
    );
  }

  Future<void> showLogOutDialog(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Logout'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
              onPressed: () async {
                (await Api.cookieJar).deleteAll();
                // userController.user(User());
                _logOut();
                _ehSettingService.isSiteEx.value = false;
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
