import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/controller/tabview_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/src/widgets/framework.dart';
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

class TopListViewController extends TabViewController {
  final RxString _title = ''.obs;

  final EhConfigService _ehConfigService = Get.find();

  @override
  void onInit() {
    fetchNormal = Api.getToplist;
    tabTag = EHRoutes.toplist;
    super.onInit();
  }

  String get toplistText {
    switch (_ehConfigService.toplist) {
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
    return toplistTextMap[_ehConfigService.toplist] ??
        L10n.of(Get.context!).tab_toplist;
  }

  Future<void> setToplist(BuildContext context) async {
    final ToplistType? type = await _ehConfigService.showToplistsSel(context);
    if (type != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }
}
