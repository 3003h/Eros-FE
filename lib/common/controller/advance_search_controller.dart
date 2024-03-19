import 'package:eros_fe/index.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class AdvanceSearchController extends ProfileController {
  final RxBool _enableAdvance = false.obs;
  bool get enableAdvance => _enableAdvance.value;
  set enableAdvance(bool val) => _enableAdvance.value = val;

  Rx<AdvanceSearch> advanceSearch = kDefAdvanceSearch.obs;

  // 重置高级搜索
  void reset() {
    advanceSearch(kDefAdvanceSearch);
  }

  /// 高级搜索参数拼接
  String getAdvanceSearchText() {
    final AdvanceSearch advanceSearchValue = advanceSearch.value;

    final String para =
        '&f_sto=${advanceSearchValue.requireGalleryTorrent ?? false ? "on" : ""}'
        '&f_sh=${advanceSearchValue.browseExpungedGalleries ?? false ? "on" : ""}'
        '&f_sr=${advanceSearchValue.searchWithMinRating ?? false ? "on" : ""}'
        '&f_srdd=${advanceSearchValue.minRating}'
        '&f_sp=${advanceSearchValue.searchBetweenPage ?? false ? "on" : ""}'
        '&f_spf=${advanceSearchValue.startPage}'
        '&f_spt=${advanceSearchValue.endPage}'
        '&f_sfl=${advanceSearchValue.disableCustomFilterLanguage ?? false ? "on" : ""}'
        '&f_sfu=${advanceSearchValue.disableCustomFilterUploader ?? false ? "on" : ""}'
        '&f_sft=${advanceSearchValue.disableCustomFilterTags ?? false ? "on" : ""}';

    return para;
  }

  Map<String, dynamic> get advanceSearchMap => advanceSearch.value.param;

  Map<String, dynamic> get favSearchMap {
    final AdvanceSearch val = advanceSearch.value;

    return <String, dynamic>{
      // if (val.favSearchName) 'sn': 'on',
      // if (val.favSearchTags) 'st': 'on',
      // if (val.favSearchNote) 'sf': 'on',
    };
  }

  @override
  void onInit() {
    super.onInit();
    _enableAdvance.value = Global.profile.enableAdvanceSearch;
    everProfile<bool>(
        _enableAdvance,
        (bool value) => Global.profile =
            Global.profile.copyWith(enableAdvanceSearch: value));

    advanceSearch.value = Global.profile.advanceSearch;
    everProfile<AdvanceSearch>(
        advanceSearch,
        (AdvanceSearch value) =>
            Global.profile = Global.profile.copyWith(advanceSearch: value));
  }
}
