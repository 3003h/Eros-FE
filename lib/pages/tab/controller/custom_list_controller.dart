import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:get/get.dart';

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
