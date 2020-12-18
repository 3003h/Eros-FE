import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  List<GalleryItem> historys = <GalleryItem>[];

  final EhConfigController _ehConfigController = Get.find();

  void addHistory(GalleryItem galleryItem) {
    logger.d('start ${DateTime.now()}');
    final int _index = historys.indexWhere((GalleryItem element) {
      return element.gid == galleryItem.gid;
    });
    if (_index >= 0) {
      historys.removeAt(_index);
      logger.d('end removeAt: ${DateTime.now()}');
      historys.insert(0, galleryItem);
      logger.d('end insert obs :${DateTime.now()}');
    } else {
      // 检查数量限制 超限则删除最后一条
      if (_ehConfigController.maxHistory.value > 0 &&
          historys.length == _ehConfigController.maxHistory.value) {
        historys.removeLast();
      }

      historys.insert(0, galleryItem);
    }
    update();
    Global.saveHistory();
  }

  void removeHistory(int index) {
    historys.removeAt(index);
    update();
    Global.saveHistory();
  }

  void cleanHistory() {
    historys.clear();
    update();
    Global.saveHistory();
  }

  @override
  void onInit() {
    super.onInit();

    final History _history = Global.history;
    historys = _history.history;
  }
}
