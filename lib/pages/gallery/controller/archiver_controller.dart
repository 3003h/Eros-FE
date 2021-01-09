import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class ArchiverController extends GetxController
    with StateMixin<ArchiverProvider> {
  ArchiverController({this.pageController});

  final GalleryPageController pageController;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<ArchiverProvider> _fetch() async {
    logger.d(pageController.galleryItem.archiverLink);
    return await Api.getArchiver(pageController.galleryItem.archiverLink);
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
        pageController.galleryItem.archiverLink, dlres);
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
