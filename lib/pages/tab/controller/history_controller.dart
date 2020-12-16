import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/history_model.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HistoryController extends GetxController
    with StateMixin<List<GalleryItem>> {
  Future<List<GalleryItem>> futureBuilderFuture;
  Widget lastListWidget;
  HistoryModel historyModel;

  @override
  void onInit() {
    super.onInit();
    historyModel = Provider.of<HistoryModel>(Get.context, listen: false);

    loadData().then((List<GalleryItem> value) {
      change(value, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    });
  }

  Future<List<GalleryItem>> loadData() async {
    logger.v('_loadData ');
    final List<GalleryItem> historys = historyModel.history;

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
                historyModel.cleanHistory();
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
