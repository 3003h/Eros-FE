import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/network/request.dart';
import 'package:get/get.dart';

import '../../../fehviewer.dart';

const kEhMyTags = EhMytags(tagsets: []);

class EhMyTagsController extends GetxController {
  static String idUsertagList = 'idUsertagList';

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool val) => _isLoading.value = val;

  final _ehMyTags = kEhMyTags.obs;
  EhMytags get ehMyTags => _ehMyTags.value;
  set ehMyTags(EhMytags val) => _ehMyTags.value = val;

  List<EhUsertag> get usertags => ehMyTags.usertags ?? [];

  final EhConfigService ehConfigService = Get.find();
  final LocaleService localeService = Get.find();

  String get apikey => ehMyTags.apikey ?? '';
  String get apiuid => ehMyTags.apiuid ?? '';

  String currSelected = '';

  bool get isTagTranslat =>
      ehConfigService.isTagTranslat && localeService.isLanguageCodeZh;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<String?> getTextTranslate(String text) async {
    String namespace = '';
    if (text.contains(':')) {
      namespace = text.split(':')[0];
    }
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpase(
      text,
      namespace: namespace,
    );
    if (tranText?.trim() != text) {
      return tranText;
    }
    return null;
  }

  Future<EhMytags?> loadData({bool refresh = false}) async {
    // isLoading = true;
    try {
      final mytags = await getMyTags(
        refresh: refresh || Global.forceRefreshUconfig,
        selectTagset: currSelected,
      );
      isLoading = false;

      if (mytags != null) {
        ehMyTags = mytags;
        return mytags;
      }

      // update([idUsertagList]);
    } catch (e) {
      rethrow;
    } finally {
      // isLoading = false;
    }
    return null;
  }

  Future<void> reloadData() async {
    await loadData(refresh: true);
  }

  Future<void> changeTagset(String tagSet) async {
    isLoading = true;
    try {
      final mytags = await getMyTags(
        refresh: true,
        selectTagset: tagSet,
      );
      if (mytags != null) {
        ehMyTags = mytags;
        currSelected = tagSet;
      }
      isLoading = false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Map<String, EhMytagSet> get tagsetMap {
    final Map<String, EhMytagSet> _map = <String, EhMytagSet>{};
    for (final _tagset in ehMyTags.tagsets) {
      _map['${_tagset.value}'] = _tagset;
    }
    return _map;
  }

  EhMytagSet? get curTagSet => tagsetMap[currSelected];

  void deleteTagset() {}

  void crtNewTagset() {}

  void deleteUsertag(int index) {
    logger.d('deleteUsertag $index');
    final temp = ehMyTags.clone();
    final _id = ehMyTags.usertags?[index].tagid;
    temp.usertags?.removeAt(index);
    ehMyTags = temp;
    if (_id != null) {
      deleteUserTag(usertags: [_id]);
    }
  }
}
