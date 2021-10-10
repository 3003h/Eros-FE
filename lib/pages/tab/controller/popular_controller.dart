import 'package:fehviewer/route/routes.dart';

import '../fetch_list.dart';
import 'tabview_controller.dart';

class PopularViewController extends TabViewController {
  @override
  void onInit() {
    tabTag = EHRoutes.popular;
    super.onInit();
  }

  @override
  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return PopularFetchListClient(fetchParams: fetchParams);
  }
}
