import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/pages/gallery/gallery_repository.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:get/get.dart';

import 'controller/archiver_controller.dart';
import 'controller/comment_controller.dart';
import 'controller/gallery_fav_controller.dart';
import 'controller/gallery_page_controller.dart';
import 'controller/rate_controller.dart';
import 'controller/taginfo_controller.dart';
import 'controller/torrent_controller.dart';

void initPageController({String? tag}) {
  Get.lazyPut(() => CommentController(), tag: tag ?? pageCtrlTag);

  Get.lazyPut(() => RateController(), tag: tag ?? pageCtrlTag);

  Get.lazyPut(() => TorrentController(), tag: tag ?? pageCtrlTag);

  Get.lazyPut(() => ArchiverController(), tag: tag ?? pageCtrlTag);

  Get.lazyPut(() => GalleryFavController(), tag: tag ?? pageCtrlTag);

  Get.lazyPut(() => TagInfoController(), tag: tag ?? pageCtrlTag);
}

void deletePageController({String? tag}) {
  return;
  logger.t('deletePageController ${tag ?? pageCtrlTag}');

  // GalleryPageController
  if (Get.isRegistered<GalleryPageController>(tag: tag ?? pageCtrlTag))
    Get.delete<GalleryPageController>(tag: tag ?? pageCtrlTag);

  if (Get.isRegistered<RateController>(tag: tag ?? pageCtrlTag))
    Get.delete<RateController>(tag: tag ?? pageCtrlTag);
  if (Get.isRegistered<TorrentController>(tag: tag ?? pageCtrlTag))
    Get.delete<TorrentController>(tag: tag ?? pageCtrlTag);
  if (Get.isRegistered<ArchiverController>(tag: tag ?? pageCtrlTag))
    Get.delete<ArchiverController>(tag: tag ?? pageCtrlTag);
  if (Get.isRegistered<CommentController>(tag: tag ?? pageCtrlTag))
    Get.delete<CommentController>(tag: tag ?? pageCtrlTag);

  if (Get.isRegistered<TagInfoController>(tag: tag ?? pageCtrlTag))
    Get.delete<TagInfoController>(tag: tag ?? pageCtrlTag);

  if (Get.isRegistered<GalleryRepository>()) {
    Get.delete<GalleryRepository>();
  }

  // Get.find<DepthService>().popPageCtrl();
}
