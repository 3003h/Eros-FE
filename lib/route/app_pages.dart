import 'package:FEhViewer/pages/login/login_page.dart';
import 'package:FEhViewer/pages/setting/about_page.dart';
import 'package:FEhViewer/pages/setting/advanced_setting_page.dart';
import 'package:FEhViewer/pages/setting/download_setting_page.dart';
import 'package:FEhViewer/pages/setting/eh_setting_page.dart';
import 'package:FEhViewer/pages/setting/view_setting_page.dart';
import 'package:FEhViewer/pages/tab/bindings/splash_binding.dart';
import 'package:FEhViewer/pages/tab/bindings/tabhome_binding.dart';
import 'package:FEhViewer/pages/tab/view/favorite_sel_page.dart';
import 'package:FEhViewer/pages/tab/view/splash_page.dart';
import 'package:FEhViewer/pages/tab/view/tabhome_page.dart';
import 'package:get/get.dart';

import 'routes.dart';

// ignore: avoid_classes_with_only_static_members
class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: EHRoutes.root,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: EHRoutes.home,
      page: () => TabHome(),
      binding: TabHomeBinding(),
    ),
    GetPage(
      name: EHRoutes.selFavorie,
      page: () => FavoriteSelectorPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.ehSetting,
      page: () => EhSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.advancedSetting,
      page: () => AdvancedSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.about,
      page: () => AboutPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.downloadSetting,
      page: () => DownloadSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.viewSeting,
      page: () => ViewSettingPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.login,
      page: () => LoginPage(),
      transition: Transition.cupertino,
    ),
  ];
}
