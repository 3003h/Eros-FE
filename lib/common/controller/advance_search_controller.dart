import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class AdvanceSearchController extends ProfileController {
  final RxBool _enableAdvance = false.obs;
  bool get enableAdvance => _enableAdvance.value ?? false;
  set enableAdvance(bool val) => _enableAdvance.value = val;

  Rx<AdvanceSearch> advanceSearch = kDefAdvanceSearch.obs;

  // 重置高级搜索
  void reset() {
    advanceSearch(kDefAdvanceSearch);
  }

  /// 高级搜索参数拼接
  String getAdvanceSearchText() {
    final AdvanceSearch advanceSearchValue =
        advanceSearch.value ?? kDefAdvanceSearch;

    final String para =
        '&f_sname=${advanceSearchValue.searchGalleryName ? "on" : ""}'
        '&f_stags=${advanceSearchValue.searchGalleryTags ? "on" : ""}'
        '&f_sdesc=${advanceSearchValue.searchGalleryDesc ? "on" : ""}'
        '&f_storr=${advanceSearchValue.searchToreenFilenames ? "on" : ""}'
        '&f_sto=${advanceSearchValue.onlyShowWhithTorrents ? "on" : ""}'
        '&f_sdt1=${advanceSearchValue.searchLowPowerTags ? "on" : ""}'
        '&f_sdt2=${advanceSearchValue.searchDownvotedTags ? "on" : ""}'
        '&f_sh=${advanceSearchValue.searchExpunged ? "on" : ""}'
        '&f_sr=${advanceSearchValue.searchWithminRating ? "on" : ""}'
        '&f_srdd=${advanceSearchValue.minRating}'
        '&f_sp=${advanceSearchValue.searchBetweenpage ? "on" : ""}'
        '&f_spf=${advanceSearchValue.startPage}'
        '&f_spt=${advanceSearchValue.endPage}'
        '&f_sfl=${advanceSearchValue.disableDFLanguage ? "on" : ""}'
        '&f_sfu=${advanceSearchValue.disableDFUploader ? "on" : ""}'
        '&f_sft=${advanceSearchValue.disableDFTags ? "on" : ""}';

    return para;
  }

  Map<String, dynamic> get advanceSearchMap {
    final AdvanceSearch val = advanceSearch.value ?? kDefAdvanceSearch;

    return <String, dynamic>{
      if (val.searchGalleryName) 'f_sname': 'on',
      if (val.searchGalleryTags) 'f_stags': 'on',
      if (val.searchGalleryDesc) 'f_sdesc': 'on',
      if (val.searchToreenFilenames) 'f_storr': 'on',
      if (val.onlyShowWhithTorrents) 'f_sto': 'on',
      if (val.searchLowPowerTags) 'f_sdt1': 'on',
      if (val.searchDownvotedTags) 'f_sdt2': 'on',
      if (val.searchExpunged) 'f_sh': 'on',
      if (val.searchWithminRating) 'f_sr': 'on',
      if (val.searchWithminRating) 'f_srdd': val.minRating,
      if (val.searchBetweenpage) 'f_sp': 'on',
      if (val.startPage.isNotEmpty) 'f_spf': val.startPage,
      if (val.endPage.isNotEmpty) 'f_spt': val.endPage,
      if (val.disableDFTags) 'f_sfl': 'on',
      if (val.disableDFTags) 'f_sfu': 'on',
      if (val.disableDFTags) 'f_sft': 'on',
    };
  }

  Map<String, dynamic> get favSearchMap {
    final AdvanceSearch val = advanceSearch.value ?? kDefAdvanceSearch;

    return <String, dynamic>{
      if (val.favSearchName) 'sn': 'on',
      if (val.favSearchTags) 'st': 'on',
      if (val.favSearchNote) 'sf': 'on',
    };
  }

  @override
  void onInit() {
    super.onInit();
    _enableAdvance.value = Global.profile.enableAdvanceSearch;
    everProfile<bool>(
        _enableAdvance as RxInterface<bool>,
        (bool value) => Global.profile =
            Global.profile.copyWith(enableAdvanceSearch: value));

    advanceSearch.value = Global.profile.advanceSearch;
    everProfile<AdvanceSearch>(
        advanceSearch as RxInterface<AdvanceSearch>,
        (AdvanceSearch value) =>
            Global.profile = Global.profile.copyWith(advanceSearch: value));
  }
}
