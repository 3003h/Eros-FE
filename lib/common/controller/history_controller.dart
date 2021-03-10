import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  List<GalleryItem> historys = <GalleryItem>[];

  final EhConfigService _ehConfigService = Get.find();
  final GStore _gStore = Get.find<GStore>();

  void addHistory(GalleryItem galleryItem) {
    final int _index = historys.indexWhere((GalleryItem element) {
      return element.gid == galleryItem.gid;
    });
    if (_index >= 0) {
      historys.removeAt(_index);
      historys.insert(0, galleryItem);
    } else {
      // 检查数量限制 超限则删除最后一条
      if (_ehConfigService.maxHistory.value > 0 &&
          historys.length == _ehConfigService.maxHistory.value) {
        historys.removeLast();
      }

      historys.insert(0, galleryItem);
    }
    update();
    _gStore.historys = historys;
  }

  void removeHistory(int index) {
    historys.removeAt(index);
    update();
    _gStore.historys = historys;
  }

  void cleanHistory() {
    historys.clear();
    update();
    _gStore.historys = historys;
  }

  @override
  void onInit() {
    super.onInit();

    historys = _gStore.historys;
  }
}
