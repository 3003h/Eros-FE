import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/pages/tab/controller/favorite_controller.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/history_controller.dart';
import 'package:fehviewer/pages/tab/controller/popular_controller.dart';
import 'package:fehviewer/pages/tab/controller/setting_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/controller/watched_controller.dart';
import 'package:get/get.dart';

class TabHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TabHomeController(), fenix: true);
    Get.lazyPut(() => PopularViewController(), fenix: true);
    Get.lazyPut(() => WatchedViewController(), fenix: true);
    Get.lazyPut(() => GalleryViewController(), fenix: true);
    Get.lazyPut(() => FavoriteViewController(), fenix: true);
    Get.lazyPut(() => SettingViewController(), fenix: true);

    Get.lazyPut(() => HistoryViewController(), fenix: true);
    Get.lazyPut(() => DownloadViewController(), fenix: true);
  }
}
