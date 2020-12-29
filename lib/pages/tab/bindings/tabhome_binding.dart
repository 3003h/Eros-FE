import 'package:fehviewer/common/controller/cache_controller.dart';
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
    Get.lazyPut(() => SettingViewController());

    Get.lazyPut(() => HistoryViewController(), fenix: true);

    Get.put(CacheController());
  }
}
