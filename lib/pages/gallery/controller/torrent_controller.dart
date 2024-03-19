import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

class TorrentController extends GetxController
    with StateMixin<TorrentProvider> {
  TorrentController();

  late GalleryPageController pageController;
  GalleryPageState get _pageState => pageController.gState;
  late String torrentTk;
  bool isRefresh = false;

  @override
  void onInit() {
    super.onInit();
    pageController = Get.find(tag: pageCtrlTag);
    _loadData();
  }

  Future<TorrentProvider> _fetch() async {
    final _torrentLink = '${Api.getBaseUrl()}/gallerytorrents.php'
        '?gid=${_pageState.gid}&t=${_pageState.galleryProvider?.token}';
    logger.d(_torrentLink);
    return await getTorrent(_torrentLink);
  }

  Future<void> _loadData() async {
    try {
      final TorrentProvider provider = await _fetch();
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

  Future<String> _fetchTk() async {
    return await getTorrentToken(
        _pageState.gid, _pageState.galleryProvider?.token ?? '',
        refresh: isRefresh);
  }
}

class TorrentProvider {
  late List<GalleryTorrent> torrents;
  late String torrentToken;
}
