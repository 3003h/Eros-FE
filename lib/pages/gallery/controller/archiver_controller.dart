import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

class ArchiverController extends GetxController
    with StateMixin<ArchiverProvider> {
  ArchiverController();

  GalleryPageController get pageController => Get.find(tag: pageCtrlTag);
  GalleryPageState get _pageState => pageController.gState;
  late final ArchiverDownloadController _downloadController;
  late String _archiverLink;

  @override
  void onInit() {
    super.onInit();
    if (GetPlatform.isMobile) {
      _downloadController = Get.find();
    }
    _loadData();
  }

  Future<ArchiverProvider> _fetch() async {
    _archiverLink =
        '${Api.getBaseUrl()}/archiver.php?gid=${_pageState.galleryItem?.gid}'
        '&token=${_pageState.galleryItem?.token}'
        '&or=${_pageState.galleryItem?.archiverLink}';
    logger.d(_archiverLink);
    return await getArchiver(_archiverLink);
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
    logger.d('downloadRemote  $_archiverLink $dlres');
    final String response =
        await postArchiverRemoteDownload(_archiverLink, dlres);
    showToast(response);
  }

  Future<void> downloadLoacal({
    required String dltype,
    required String dlcheck,
  }) async {
    final String _url = await postArchiverLocalDownload(
      _archiverLink,
      dltype: dltype,
      dlcheck: dlcheck,
    );
    Get.back();
    logger.d('archiver downloadLoacal $_url');
    _downloadController.downloadArchiverFile(
      gid: _pageState.galleryItem?.gid ?? '0',
      title: _pageState.title,
      dlType: dltype,
      url: _url,
      imgUrl: _pageState.galleryItem?.imgUrl,
      galleryUrl: _pageState.galleryItem?.url,
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
