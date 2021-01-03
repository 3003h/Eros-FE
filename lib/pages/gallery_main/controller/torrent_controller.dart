import 'package:fehviewer/models/galleryTorrent.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class TorrentController extends GetxController with StateMixin<String> {
  TorrentController({this.pageController});

  final GalleryPageController pageController;
  String torrentTk;
  List<GalleryTorrent> torrents;
  bool isRefresh = false;

  @override
  void onInit() {
    super.onInit();
    // pageController = Get.find(tag: pageCtrlDepth);
    torrents = pageController.galleryItem.torrents;
    _fetchData();
  }

  void _fetchData() {
    _fetchTk().then((value) {
      change(value, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error());
    });
  }

  Future<String> _fetchTk() async {
    return await Api.getTorrentToken(
        pageController.gid, pageController.galleryItem.token,
        refresh: isRefresh);
  }

  Future<void> reload() async {
    change(null, status: RxStatus.loading());
    _fetchData();
  }
}
