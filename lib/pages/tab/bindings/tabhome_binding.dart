import 'package:FEhViewer/common/controller/history_controller.dart';
import 'package:FEhViewer/common/controller/localfav_controller.dart';
import 'package:FEhViewer/common/controller/quicksearch_controller.dart';
import 'package:FEhViewer/pages/tab/controller/favorite_controller.dart';
import 'package:FEhViewer/pages/tab/controller/gallery_controller.dart';
import 'package:FEhViewer/pages/tab/controller/history_controller.dart';
import 'package:FEhViewer/pages/tab/controller/popular_controller.dart';
import 'package:FEhViewer/pages/tab/controller/setting_controller.dart';
import 'package:FEhViewer/pages/tab/controller/tabhome_controller.dart';
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
    Get.lazyPut(() => QuickSearchController(), fenix: true);
    Get.lazyPut(() => LocalFavController());
    Get.lazyPut(() => HistoryController());
  }
}
