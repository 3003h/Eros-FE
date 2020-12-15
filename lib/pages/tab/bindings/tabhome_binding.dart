import 'package:FEhViewer/pages/tab/controller/gallery_controller.dart';
import 'package:FEhViewer/pages/tab/controller/popular_controller.dart';
import 'package:FEhViewer/pages/tab/controller/tabhome_controller.dart';
import 'package:get/get.dart';

class TabHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TabHomeController());
    Get.lazyPut(() => PopularController());
    Get.lazyPut(() => GalleryController());
  }
}
