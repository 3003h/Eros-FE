import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/pages/tab/controller/default_tabview_controller.dart';
import 'package:eros_fe/pages/tab/fetch_list.dart';
import 'package:eros_fe/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum ToplistType {
  yesterday,
  month,
  year,
  all,
}

const Map<ToplistType, String> topListVal = {
  ToplistType.yesterday: '15',
  ToplistType.month: '13',
  ToplistType.year: '12',
  ToplistType.all: '11',
};

class TopListViewController extends DefaultTabViewController {
  final RxString _title = ''.obs;

  @override
  void onInit() {
    heroTag = EHRoutes.toplist;
    super.onInit();
  }

  @override
  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return ToplistFetchListClient(fetchParams: fetchParams);
  }

  String get toplistText {
    switch (ehSettingService.toplist) {
      case ToplistType.yesterday:
        return 'D';
      case ToplistType.month:
        return 'M';
      case ToplistType.year:
        return 'Y';
      case ToplistType.all:
        return 'A';
    }
  }

  String get getTopListTitle {
    final toplistTextMap = <ToplistType, String>{
      ToplistType.yesterday: L10n.of(Get.context!).tolist_yesterday,
      ToplistType.month: L10n.of(Get.context!).tolist_past_month,
      ToplistType.year: L10n.of(Get.context!).tolist_past_year,
      ToplistType.all: L10n.of(Get.context!).tolist_alltime,
    };
    return toplistTextMap[ehSettingService.toplist] ??
        L10n.of(Get.context!).tab_toplist;
  }

  Future<void> setToplist(BuildContext context) async {
    final ToplistType? type = await ehSettingService.showToplistsSel(context);
    if (type != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }
}
