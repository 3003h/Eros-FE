import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class AdvanceSearchController extends ProfileController {
  RxBool enableAdvance = false.obs;
  Rx<AdvanceSearch> advanceSearch = (AdvanceSearch()
        ..searchGalleryName = true
        ..searchGalleryTags = true)
      .obs;

  void reset() {
    advanceSearch(AdvanceSearch()
      ..searchGalleryName = true
      ..searchGalleryTags = true);
  }

  @override
  void onInit() {
    super.onInit();
    enableAdvance.value = Global.profile.enableAdvanceSearch ?? false;
    everSaveProfile<bool>(enableAdvance,
        (bool value) => Global.profile.enableAdvanceSearch = value);

    advanceSearch.value = Global.profile.advanceSearch;
    everSaveProfile<AdvanceSearch>(advanceSearch,
        (AdvanceSearch value) => Global.profile.advanceSearch = value);
  }
}
