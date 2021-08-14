import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_fav_controller.dart';
import 'package:fehviewer/pages/gallery/controller/rate_controller.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:get/get.dart';

class GalleryBinding extends Bindings {
  GalleryBinding({this.galleryRepository});

  final GalleryRepository? galleryRepository;

  @override
  void dependencies() {
    // Get.lazyPut(() => CommentController(), tag: pageCtrlDepth);
    //
    // Get.lazyPut(() => RateController(), tag: pageCtrlDepth);
    //
    // Get.lazyPut(() => TorrentController(), tag: pageCtrlDepth);
    //
    // Get.lazyPut(() => ArchiverController(), tag: pageCtrlDepth);
    //
    // Get.lazyPut(() => GalleryFavController(), tag: pageCtrlDepth);
    //
    // Get.lazyPut(() => TagInfoController(), tag: pageCtrlDepth);
  }
}
