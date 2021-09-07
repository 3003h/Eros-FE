import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

import 'controller/archiver_controller.dart';
import 'controller/comment_controller.dart';
import 'controller/gallery_fav_controller.dart';
import 'controller/gallery_page_controller.dart';
import 'controller/rate_controller.dart';
import 'controller/taginfo_controller.dart';
import 'controller/torrent_controller.dart';

void initPageController({String? tag}) {
  Get.lazyPut(() => CommentController(), tag: tag ?? pageCtrlDepth);

  Get.lazyPut(() => RateController(), tag: tag ?? pageCtrlDepth);

  Get.lazyPut(() => TorrentController(), tag: tag ?? pageCtrlDepth);

  Get.lazyPut(() => ArchiverController(), tag: tag ?? pageCtrlDepth);

  Get.lazyPut(() => GalleryFavController(), tag: tag ?? pageCtrlDepth);

  Get.lazyPut(() => TagInfoController(), tag: tag ?? pageCtrlDepth);
}

void deletePageController({String? tag}) {
  logger.v('deletePageController ${tag ?? pageCtrlDepth}');

  // GalleryPageController
  if (Get.isRegistered<GalleryPageController>(tag: tag ?? pageCtrlDepth))
    Get.delete<GalleryPageController>(tag: tag ?? pageCtrlDepth);

  if (Get.isRegistered<RateController>(tag: tag ?? pageCtrlDepth))
    Get.delete<RateController>(tag: tag ?? pageCtrlDepth);
  if (Get.isRegistered<TorrentController>(tag: tag ?? pageCtrlDepth))
    Get.delete<TorrentController>(tag: tag ?? pageCtrlDepth);
  if (Get.isRegistered<ArchiverController>(tag: tag ?? pageCtrlDepth))
    Get.delete<ArchiverController>(tag: tag ?? pageCtrlDepth);
  if (Get.isRegistered<CommentController>(tag: tag ?? pageCtrlDepth))
    Get.delete<CommentController>(tag: tag ?? pageCtrlDepth);

  if (Get.isRegistered<TagInfoController>(tag: tag ?? pageCtrlDepth))
    Get.delete<TagInfoController>(tag: tag ?? pageCtrlDepth);

  if (Get.isRegistered<GalleryRepository>()) {
    Get.delete<GalleryRepository>();
  }

  // Get.find<DepthService>().popPageCtrl();
}
