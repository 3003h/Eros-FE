import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final List<GalleryItem> _historys = <GalleryItem>[];
  List<GalleryItem> get historys {
    _historys
        .sort((a, b) => (b.lastViewTime ?? 0).compareTo(a.lastViewTime ?? 0));
    return _historys;
  }

  final EhConfigService _ehConfigService = Get.find();
  final GStore _gStore = Get.find<GStore>();

  void addHistory(GalleryItem galleryItem) {
    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    final _item = galleryItem.copyWith(lastViewTime: nowTime);

    final int _index = historys.indexWhere((GalleryItem element) {
      return element.gid == _item.gid;
    });
    if (_index >= 0) {
      historys.removeAt(_index);
      historys.insert(0, _item);
      hiveHelper.addHistory(_item);
    } else {
      // 检查数量限制 超限则删除最后一条
      if (_ehConfigService.maxHistory.value > 0 &&
          historys.length == _ehConfigService.maxHistory.value) {
        hiveHelper.removeHistory(historys.last.gid ?? '');
        historys.removeLast();
      }

      historys.insert(0, _item);
      hiveHelper.addHistory(_item);
    }
    update();
  }

  void cleanHistory() {
    historys.clear();
    update();
    hiveHelper.cleanHistory();
    _gStore.historys = historys;
    // _gStore.historys = historys;
  }

  @override
  void onInit() {
    super.onInit();

    // historys = _gStore.historys;
    // _historys = hiveHelper.getAll();
    _historys.addAll(hiveHelper.getAll());
  }
}
