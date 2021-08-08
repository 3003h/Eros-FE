import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:get/get.dart';

import 'common/controller/advance_search_controller.dart';
import 'common/controller/archiver_download_controller.dart';
import 'common/controller/auto_lock_controller.dart';
import 'common/controller/cache_controller.dart';
import 'common/controller/download_controller.dart';
import 'common/controller/gallerycache_controller.dart';
import 'common/controller/history_controller.dart';
import 'common/controller/localfav_controller.dart';
import 'common/controller/quicksearch_controller.dart';
import 'common/controller/tag_trans_controller.dart';
import 'common/controller/user_controller.dart';
import 'common/service/depth_service.dart';
import 'common/service/dns_service.dart';
import 'common/service/ehconfig_service.dart';
import 'common/service/layout_service.dart';
import 'common/service/locale_service.dart';
import 'common/service/theme_service.dart';
import 'pages/controller/fav_dialog_controller.dart';
import 'pages/controller/favorite_sel_controller.dart';
import 'pages/tab/controller/download_view_controller.dart';
import 'pages/tab/controller/favorite_controller.dart';
import 'pages/tab/controller/gallery_controller.dart';
import 'pages/tab/controller/history_controller.dart';
import 'pages/tab/controller/popular_controller.dart';
import 'pages/tab/controller/setting_controller.dart';
import 'pages/tab/controller/splash_controller.dart';
import 'pages/tab/controller/tabhome_controller.dart';
import 'pages/tab/controller/unlock_page_controller.dart';
import 'pages/tab/controller/watched_controller.dart';

void getinit() {
  Get.lazyPut(() => EhConfigService(), fenix: true);

  //LocaleController
  Get.lazyPut(() => LocaleService(), fenix: true);
  // ThemeController
  Get.lazyPut(() => ThemeService(), fenix: true);
  // DnsConfigController
  Get.put(DnsService(), permanent: true);
  Get.put(DepthService());

  Get.lazyPut(() => LayoutServices(), fenix: true);

  /// 一些全局设置或者控制
  Get.lazyPut(() => AutoLockController(), fenix: true);
  Get.lazyPut(() => LocalFavController(), fenix: true);
  Get.lazyPut(() => HistoryController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => GalleryCacheController(), fenix: true);
  Get.lazyPut(() => CacheController(), fenix: true);

  Get.put(DownloadController());
  Get.put(ArchiverDownloadController());

  Get.lazyPut(() => TabHomeController(), fenix: true);
  Get.lazyPut(() => PopularViewController(), fenix: true);
  Get.lazyPut(() => WatchedViewController(), fenix: true);
  Get.lazyPut(() => GalleryViewController(), fenix: true);
  Get.lazyPut(() => SettingViewController(), fenix: true);

  Get.lazyPut(() => HistoryViewController(), fenix: true);
  Get.lazyPut(() => DownloadViewController(), fenix: true);
  Get.lazyPut(() => FavoriteViewController(), fenix: true);
  Get.lazyPut(() => TopListViewController(), fenix: true);

  Get.lazyPut(() => QuickSearchController(), fenix: true);
  Get.lazyPut(() => AdvanceSearchController(), fenix: true);
  Get.lazyPut(() => FavDialogController(), fenix: true);
  Get.lazyPut(() => FavoriteSelectorController(), fenix: true);

  Get.lazyPut(() => UnlockPageController(), fenix: true);
  Get.lazyPut(() => TagTransController(), fenix: true);

  Get.lazyPut(() => SplashController());
}
