import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/logger.dart';
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
      context: Get.context!,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(S.of(context).t_Clear_all_history),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
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
