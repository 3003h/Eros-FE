import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:get/get.dart';

import 'default_tabview_controller.dart';

class GalleryViewController extends DefaultTabViewController {
  GalleryViewController();

  String get title {
    return L10n.of(Get.context!).tab_gallery;
  }

  @override
  void onInit() {
    heroTag = EHRoutes.gallery;
    super.onInit();
  }
}
