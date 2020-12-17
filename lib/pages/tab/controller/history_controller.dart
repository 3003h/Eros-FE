import 'package:FEhViewer/common/controller/history_controller.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HistoryViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  final HistoryController historyController = Get.find();

  @override
  void onInit() {
    super.onInit();

    loadData().then((List<GalleryItem> value) {
      change(value, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    });
  }

  Future<List<GalleryItem>> loadData() async {
    logger.v('_loadData ');
    final List<GalleryItem> historys = historyController.historys;

    return Future<List<GalleryItem>>.value(historys);
  }

  Future<void> reloadData() async {
    final List<GalleryItem> gallerItemBeans = await loadData();
    change(gallerItemBeans);
    update();
  }

  // 清除历史记录 Dialog
  Future<void> clearHistory() async {
    return showCupertinoDialog<void>(
      context: Get.context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('清除所有历史?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                historyController.cleanHistory();
                Get.back();
                reloadData();
              },
            ),
          ],
        );
      },
    );
  }
}
