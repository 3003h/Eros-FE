import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:get/get.dart';

import 'tabview_controller.dart';

class GalleryViewController extends TabViewController {
  GalleryViewController({int? cats}) : super(cats: cats);

  String get title {
    if (cats != null) {
      return EHConst.cats.entries
          .firstWhere((MapEntry<String, int> element) =>
              element.value == EHConst.sumCats - (cats ?? 0))
          .key;
    } else {
      return L10n.of(Get.context!).tab_gallery;
    }
  }

  @override
  void onInit() {
    // fetchNormal = getGallery;
    tabTag = EHRoutes.gallery;
    super.onInit();
  }

  // @override
  // FetchListClient getFetchListClient(FetchConfig fetchConfig) {
  //   return FetchListClient(fetchConfig: fetchConfig);
  // }

}
