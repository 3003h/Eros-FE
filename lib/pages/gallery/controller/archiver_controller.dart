import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class ArchiverController extends GetxController
    with StateMixin<ArchiverProvider> {
  ArchiverController();

  GalleryPageController get pageController => Get.find(tag: pageCtrlDepth);
  final ArchiverDownloadController _downloadController = Get.find();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<ArchiverProvider> _fetch() async {
    logger.d(pageController.galleryItem.archiverLink);
    return await Api.getArchiver(pageController.galleryItem.archiverLink ?? '');
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

  Future<void> downloadRemote(String dlres) async {
    final String response = await Api.postArchiverRemoteDownload(
        pageController.galleryItem.archiverLink ?? '', dlres);
    showToast(response);
  }

  Future<void> downloadLoacal({
    required String dltype,
    required String dlcheck,
  }) async {
    Get.back();
    final String _url = await Api.postArchiverLocalDownload(
        pageController.galleryItem.archiverLink ?? '',
        dltype: dltype,
        dlcheck: dlcheck);
    _downloadController.downloadArchiverFile(
      gid: pageController.galleryItem.gid ?? '',
      title: pageController.title,
      dlType: dltype,
      url: _url,
    );
  }
}

class ArchiverProviderItem {
  String? dltype;
  String? resolution;
  String? dlres;
  String? size;
  String? price;
}

class ArchiverProvider {
  String? gp;
  String? credits;
  List<ArchiverProviderItem>? hItems;
  List<ArchiverProviderItem>? dlItems;
}
