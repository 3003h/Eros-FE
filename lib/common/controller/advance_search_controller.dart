import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class AdvanceSearchController extends ProfileController {
  final RxBool _enableAdvance = false.obs;
  bool get enableAdvance => _enableAdvance.value;
  set enableAdvance(bool val) => _enableAdvance.value = val;

  Rx<AdvanceSearch> advanceSearch = (AdvanceSearch()
        ..searchGalleryName = true
        ..searchGalleryTags = true)
      .obs;

  // 重置高级搜索
  void reset() {
    advanceSearch(AdvanceSearch()
      ..searchGalleryName = true
      ..searchGalleryTags = true);
  }

  /// 高级搜索参数拼接
  String getAdvanceSearchText() {
    final AdvanceSearch advanceSearchValue = advanceSearch.value;

    final String para =
        '&f_sname=${advanceSearchValue.searchGalleryName ?? false ? "on" : ""}'
        '&f_stags=${advanceSearchValue.searchGalleryTags ?? false ? "on" : ""}'
        '&f_sdesc=${advanceSearchValue.searchGalleryDesc ?? false ? "on" : ""}'
        '&f_storr=${advanceSearchValue.searchToreenFilenames ?? false ? "on" : ""}'
        '&f_sto=${advanceSearchValue.onlyShowWhithTorrents ?? false ? "on" : ""}'
        '&f_sdt1=${advanceSearchValue.searchLowPowerTags ?? false ? "on" : ""}'
        '&f_sdt2=${advanceSearchValue.searchDownvotedTags ?? false ? "on" : ""}'
        '&f_sh=${advanceSearchValue.searchExpunged ?? false ? "on" : ""}'
        '&f_sr=${advanceSearchValue.searchWithminRating ?? false ? "on" : ""}'
        '&f_srdd=${advanceSearchValue.minRating ?? ""}'
        '&f_sp=${advanceSearchValue.searchBetweenpage ?? false ? "on" : ""}'
        '&f_spf=${advanceSearchValue.startPage ?? ""}'
        '&f_spt=${advanceSearchValue.endPage ?? ""}'
        '&f_sfl=${advanceSearchValue.disableDFLanguage ?? false ? "on" : ""}'
        '&f_sfu=${advanceSearchValue.disableDFUploader ?? false ? "on" : ""}'
        '&f_sft=${advanceSearchValue.disableDFTags ?? false ? "on" : ""}';

    return para;
  }

  @override
  void onInit() {
    super.onInit();
    enableAdvance = Global.profile.enableAdvanceSearch ?? false;
    everProfile<bool>(_enableAdvance,
        (bool value) => Global.profile.enableAdvanceSearch = value);

    advanceSearch.value = Global.profile.advanceSearch;
    everProfile<AdvanceSearch>(advanceSearch,
        (AdvanceSearch value) => Global.profile.advanceSearch = value);
  }
}
