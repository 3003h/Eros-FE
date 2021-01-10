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

  Map<String, dynamic> get advanceSearchMap {
    final AdvanceSearch val = advanceSearch.value;

    return <String, dynamic>{
      if (val.searchGalleryName ?? false) 'f_sname': 'on',
      if (val.searchGalleryTags ?? false) 'f_stags': 'on',
      if (val.searchGalleryDesc ?? false) 'f_sdesc': 'on',
      if (val.searchToreenFilenames ?? false) 'f_storr': 'on',
      if (val.onlyShowWhithTorrents ?? false) 'f_sto': 'on',
      if (val.searchLowPowerTags ?? false) 'f_sdt1': 'on',
      if (val.searchDownvotedTags ?? false) 'f_sdt2': 'on',
      if (val.searchExpunged ?? false) 'f_sh': 'on',
      if (val.searchWithminRating ?? false) 'f_sr': 'on',
      if (val.minRating != null) 'f_srdd': val.minRating,
      if (val.searchBetweenpage ?? false) 'f_sp': 'on',
      if (val.startPage?.isNotEmpty ?? false) 'f_spf': val.startPage,
      if (val.endPage?.isNotEmpty ?? false) 'f_spt': val.endPage,
      if (val.disableDFTags ?? false) 'f_sfl': 'on',
      if (val.disableDFTags ?? false) 'f_sfu': 'on',
      if (val.disableDFTags ?? false) 'f_sft': 'on',
    };
  }

  Map<String, dynamic> get favSearchMap {
    final AdvanceSearch val = advanceSearch.value;

    return <String, dynamic>{
      if (val.favSearchName ?? true) 'sn': 'on',
      if (val.favSearchTags ?? true) 'st': 'on',
      if (val.favSearchNote ?? true) 'sf': 'on',
    };
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
