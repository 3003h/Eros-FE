import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/galleryTorrent.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class TorrentController extends GetxController with StateMixin<String> {
  String torrentTk;
  GalleryPageController _pageController;
  List<GalleryTorrent> torrents;

  @override
  void onInit() {
    super.onInit();
    _pageController =
        Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');
    torrents = _pageController.galleryItem.torrents;
    _fetchTk().then((value) {
      change(value, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error());
    });
  }

  Future<String> _fetchTk() async {
    return await Api.getTorrentToken(
        _pageController.gid, _pageController.galleryItem.token,
        refresh: true);
  }
}
