import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/pages/tab/controller/favorite_controller.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/history_controller.dart';
import 'package:fehviewer/pages/tab/controller/popular_controller.dart';
import 'package:fehviewer/pages/tab/controller/setting_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:get/get.dart';

class TabHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TabHomeController());
    Get.lazyPut(() => PopularViewController());
    Get.lazyPut(() => GalleryViewController());
    Get.lazyPut(() => FavoriteViewController());
    Get.lazyPut(() => HistoryViewController());
    Get.lazyPut(() => SettingViewController());

    /// 一些全局设置或者控制
    Get.put(QuickSearchController(), permanent: true);
    Get.put(LocalFavController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(UserController(), permanent: true);

    Get.put(CacheController());
  }
}
