import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  RxList<GalleryItem> historys = <GalleryItem>[].obs;

  final EhConfigController _ehConfigController = Get.find();

  void addHistory(GalleryItem galleryItem) {
    final int _index = historys.indexWhere((GalleryItem element) {
      return element.gid == galleryItem.gid;
    });
    if (_index >= 0) {
      historys.removeAt(_index);
      historys.insert(0, galleryItem);
    } else {
      // 检查数量限制 超限则删除最后一条
      if (_ehConfigController.maxHistory.value > 0 &&
          historys.length == _ehConfigController.maxHistory.value) {
        historys.removeLast();
      }

      historys.insert(0, galleryItem);
    }
  }

  void removeHistory(int index) {
    historys.removeAt(index);
  }

  void cleanHistory() {
    historys.clear();
  }

  @override
  void onInit() {
    super.onInit();

    final History _history = Global.history;
    historys(_history.history);

    ever<List<GalleryItem>>(historys, (List<GalleryItem> value) {
      _history.history = value;
      Global.saveHistory();
    });
  }
}
