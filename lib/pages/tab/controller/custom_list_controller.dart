import 'package:fehviewer/route/routes.dart';

import 'tabview_controller.dart';

class CustomListController extends TabViewController {
  CustomListController();

  @override
  void onInit() {
    // tabTag = EHRoutes.gallery;
    tabTag = EHRoutes.coutomlist;
    super.onInit();
  }
}
