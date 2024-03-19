import 'package:eros_fe/common/controller/history_controller.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/pages/tab/controller/default_tabview_controller.dart';
import 'package:eros_fe/route/routes.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HistoryViewController extends DefaultTabViewController {
  final HistoryController historyController = Get.find();

  @override
  void onInit() {
    super.onInit();
    heroTag = EHRoutes.history;

    loadData().then((List<GalleryProvider> value) {
      change(value, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    });
  }

  Future<List<GalleryProvider>> loadData() async {
    logger.t('_loadData ');
    final List<GalleryProvider> histories = historyController.histories;

    return Future<List<GalleryProvider>>.value(histories);
  }

  Future<void> reloadData() async {
    final List<GalleryProvider> gallerItemBeans = await loadData();
    change(gallerItemBeans);
    update();
  }

  // 清除历史记录 Dialog
  Future<void> clearHistory() async {
    return showCupertinoDialog<void>(
      context: Get.context!,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(L10n.of(context).t_Clear_all_history),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
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

  Future<void> syncHistory() async {
    historyController.syncHistory();
    await Future.delayed(const Duration(seconds: 1));
  }
}
