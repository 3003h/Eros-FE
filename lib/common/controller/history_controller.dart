import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  History _history;
  RxList<GalleryItem> historys = <GalleryItem>[].obs;

  final EhConfigController ehConfigController = Get.find();

  void addHistory(GalleryItem galleryItem) {
    final int _index = historys.indexWhere((GalleryItem element) {
      return element.gid == galleryItem.gid;
    });
    if (_index >= 0) {
      _history.history.removeAt(_index);
      _history.history.insert(0, galleryItem);
    } else {
      // 检查数量限制 超限则删除最后一条
      if (ehConfigController.maxHistory.value > 0 &&
          _history.history.length == ehConfigController.maxHistory.value) {
        _history.history.removeLast();
      }

      _history.history.insert(0, galleryItem);
    }
  }

  void removeHistory(int index) {
    _history.history.removeAt(index);
  }

  void cleanHistory() {
    _history.history.clear();
  }

  @override
  void onInit() {
    super.onInit();
    _history = Global.history;
    historys(_history.history);

    ever<List<GalleryItem>>(historys, (List<GalleryItem> value) {
      _history.history = value;
      Global.saveHistory();
    });
  }
}
