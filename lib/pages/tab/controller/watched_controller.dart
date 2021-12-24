import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/fetch_list.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:get/get.dart';

import 'default_tabview_controller.dart';

class WatchedViewController extends DefaultTabViewController {
  String get title => L10n.of(Get.context!).tab_watched;

  @override
  void onInit() {
    tabTag = EHRoutes.watched;
    super.onInit();
  }

  @override
  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return WatchedFetchListClient(fetchParams: fetchParams);
  }
}
