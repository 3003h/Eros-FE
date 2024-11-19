import 'package:eros_fe/common/controller/block_controller.dart';
import 'package:eros_fe/common/controller/image_block_controller.dart';
import 'package:eros_fe/common/controller/mysql_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'common/controller/advance_search_controller.dart';
import 'common/controller/archiver_download_controller.dart';
import 'common/controller/auto_lock_controller.dart';
import 'common/controller/avatar_controller.dart';
import 'common/controller/cache_controller.dart';
import 'common/controller/download_controller.dart';
import 'common/controller/gallerycache_controller.dart';
import 'common/controller/history_controller.dart';
import 'common/controller/localfav_controller.dart';
import 'common/controller/quicksearch_controller.dart';
import 'common/controller/tag_controller.dart';
import 'common/controller/tag_trans_controller.dart';
import 'common/controller/user_controller.dart';
import 'common/controller/webdav_controller.dart';
import 'common/service/controller_tag_service.dart';
import 'common/service/dns_service.dart';
import 'common/service/ehsetting_service.dart';
import 'common/service/layout_service.dart';
import 'common/service/locale_service.dart';
import 'common/service/theme_service.dart';
import 'pages/controller/fav_controller.dart';
import 'pages/controller/favorite_sel_controller.dart';
import 'pages/setting/controller/eh_mysettings_controller.dart';
import 'pages/setting/controller/eh_mytags_controller.dart';
import 'pages/tab/controller/download_view_controller.dart';
import 'pages/tab/controller/favorite/favorite_tabbar_controller.dart';
import 'pages/tab/controller/gallery_controller.dart';
import 'pages/tab/controller/group/custom_tabbar_controller.dart';
import 'pages/tab/controller/history_view_controller.dart';
import 'pages/tab/controller/search_image_controller.dart';
import 'pages/tab/controller/setting_controller.dart';
import 'pages/tab/controller/splash_controller.dart';
import 'pages/tab/controller/tabhome_controller.dart';
import 'pages/tab/controller/toplist_controller.dart';
import 'pages/tab/controller/unlock_page_controller.dart';

void getinit() {
  Get.lazyPut(() => EhSettingService(), fenix: true);
  Get.lazyPut(() => LocaleService(), fenix: true);
  Get.lazyPut(() => ThemeService(), fenix: true);
  Get.put(DnsService(), permanent: true);
  Get.put(ControllerTagService());

  Get.lazyPut(() => LayoutServices(), fenix: true);

  /// 一些全局设置或者控制
  Get.lazyPut(() => WebdavController(), fenix: true);
  Get.lazyPut(() => MysqlController(), fenix: true);
  Get.lazyPut(() => AutoLockController(), fenix: true);
  Get.lazyPut(() => LocalFavController(), fenix: true);
  Get.lazyPut(() => HistoryController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => AvatarController(), fenix: true);
  Get.lazyPut(() => CacheController(), fenix: true);
  Get.lazyPut(() => ImageBlockController(), fenix: true);

  Get.put(GalleryCacheController(), permanent: true);

  Get.put(DownloadController(), permanent: true);
  if (GetPlatform.isMobile) {
    Get.put(ArchiverDownloadController());
  }

  debugPrint('getInit');
  Get.put(TabHomeController(), permanent: true);

  // Get.lazyPut(() => PopularViewController(), fenix: true);
  // Get.lazyPut(() => WatchedViewController(), fenix: true);
  Get.lazyPut(() => GalleryViewController(), fenix: true);
  Get.lazyPut(() => HistoryViewController(), fenix: true);
  Get.lazyPut(() => DownloadViewController(), fenix: true);
  // Get.lazyPut(() => FavoriteViewController(), fenix: true);
  Get.lazyPut(() => TopListViewController(), fenix: true);
  Get.lazyPut(() => FavoriteTabBarController(), fenix: true);
  Get.lazyPut(() => CustomTabbarController(), fenix: true);
  Get.lazyPut(() => SettingViewController(), fenix: true);
  Get.lazyPut(() => FavoriteSelectorController(), fenix: true);
  Get.lazyPut(() => QuickSearchController(), fenix: true);
  Get.lazyPut(() => AdvanceSearchController(), fenix: true);
  Get.lazyPut(() => FavController(), fenix: true);
  Get.lazyPut(() => UnlockPageController(), fenix: true);
  Get.lazyPut(() => TagTransController(), fenix: true);
  Get.lazyPut(() => SplashController());
  Get.lazyPut(() => EhMySettingsController(), fenix: true);
  Get.lazyPut(() => EhMyTagsController(), fenix: true);
  Get.lazyPut(() => TagController(), fenix: true);
  Get.lazyPut(() => SearchImageController(), fenix: true);
  Get.lazyPut(() => BlockController(), fenix: true);
}
