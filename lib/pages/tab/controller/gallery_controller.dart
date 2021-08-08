import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    fetchNormal = Api.getGallery;
    super.onInit();
  }
}
