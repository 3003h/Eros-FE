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

  Future<void> download(String resolution) async {
    final String response = await Api.postArchiverDownload(
        _pageController.galleryItem.archiverLink, resolution);
    showToast(response);
  }
}

class ArchiverProviderItem {
  String resolution;
  String size;
  String price;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiverProviderItem &&
          runtimeType == other.runtimeType &&
          resolution == other.resolution &&
          size == other.size &&
          price == other.price;

  @override
  int get hashCode => resolution.hashCode ^ size.hashCode ^ price.hashCode;

  @override
  String toString() {
    return 'ArchiverProvider{px: $resolution, size: $size, price: $price}';
  }
}

class ArchiverProvider {
  String gp;
  String credits;
  List<ArchiverProviderItem> items;
}
