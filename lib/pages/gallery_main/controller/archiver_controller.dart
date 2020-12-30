import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class ArchiverController extends GetxController
    with StateMixin<ArchiverProvider> {
  GalleryPageController _pageController;
  @override
  void onInit() {
    super.onInit();
    _pageController = Get.find(tag: pageCtrlDepth);
    _loadData();
  }

  Future<ArchiverProvider> _fetch() async {
    logger.d(_pageController.galleryItem.archiverLink);
    return await Api.getArchiver(_pageController.galleryItem.archiverLink);
  }

  Future<void> _loadData() async {
    try {
      final ArchiverProvider provider = await _fetch();
      change(provider, status: RxStatus.success());
    } catch (e, stack) {
      logger.e('$e\n$stack');
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> reload() async {
    change(state, status: RxStatus.loading());
    await _loadData();
  }

  Future<void> download(String dlres) async {
    final String response = await Api.postArchiverDownload(
        _pageController.galleryItem.archiverLink, dlres);
    showToast(response);
  }
}

class ArchiverProviderItem {
  String resolution;
  String dlres;
  String size;
  String price;
}

class ArchiverProvider {
  String gp;
  String credits;
  List<ArchiverProviderItem> items;
}
