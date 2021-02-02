import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_fav_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/rate_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:get/get.dart';

class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
        () => GalleryPageController(
              galleryRepository: Get.find(tag: pageCtrlDepth),
            ),
        tag: pageCtrlDepth);

    Get.lazyPut(() => CommentController(), tag: pageCtrlDepth);

    Get.lazyPut<RateController>(() => RateController(), tag: pageCtrlDepth);

    Get.lazyPut<TorrentController>(() => TorrentController(),
        tag: pageCtrlDepth);

    Get.lazyPut<ArchiverController>(() => ArchiverController(),
        tag: pageCtrlDepth);

    Get.lazyPut<GalleryFavController>(() => GalleryFavController(),
        tag: pageCtrlDepth);
  }
}
