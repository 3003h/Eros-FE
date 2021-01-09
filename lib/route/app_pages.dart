import 'package:fehviewer/pages/gallery/view/comment_page.dart';
import 'package:fehviewer/pages/login/login_page.dart';
import 'package:fehviewer/pages/login/web_login.dart';
import 'package:fehviewer/pages/setting/about_page.dart';
import 'package:fehviewer/pages/setting/advanced_setting_page.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:fehviewer/pages/setting/download_setting_page.dart';
import 'package:fehviewer/pages/setting/eh_setting_page.dart';
import 'package:fehviewer/pages/setting/tab_setting.dart';
import 'package:fehviewer/pages/setting/view_setting_page.dart';
import 'package:fehviewer/pages/tab/bindings/splash_binding.dart';
import 'package:fehviewer/pages/tab/bindings/tabhome_binding.dart';
import 'package:fehviewer/pages/tab/view/favorite_page.dart';
import 'package:fehviewer/pages/tab/view/favorite_sel_page.dart';
import 'package:fehviewer/pages/tab/view/history_page.dart';
import 'package:fehviewer/pages/tab/view/popular_page.dart';
import 'package:fehviewer/pages/tab/view/splash_page.dart';
import 'package:fehviewer/pages/tab/view/tabhome_page.dart';
import 'package:fehviewer/pages/tab/view/watched_page.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'routes.dart';

// ignore: avoid_classes_with_only_static_members
class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: EHRoutes.root,
      page: () => SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.home,
      page: () => TabHome(),
      binding: TabHomeBinding(),
      transition: Transition.fadeIn,
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
    GetPage(
      name: EHRoutes.webLogin,
      page: () => const WebLoginView(),
    ),
    GetPage(
      name: EHRoutes.galleryComment,
      page: () => CupertinoScaffold(body: CommentPage()),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: EHRoutes.pageSetting,
      page: () => TabSettingPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TabSettingController())),
    ),
    GetPage(
      name: EHRoutes.history,
      page: () => const HistoryTab(tabIndex: EHRoutes.history),
    ),
    GetPage(
      name: EHRoutes.watched,
      page: () => const WatchedListTab(tabIndex: EHRoutes.watched),
    ),
    GetPage(
      name: EHRoutes.favorite,
      page: () => const FavoriteTab(tabIndex: EHRoutes.favorite),
    ),
    GetPage(
      name: EHRoutes.popular,
      page: () => const PopularListTab(tabIndex: EHRoutes.popular),
    ),
  ];
}
