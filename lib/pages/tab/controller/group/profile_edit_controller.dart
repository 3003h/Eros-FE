import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/locale_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ProfileEditController extends GetxController {
  final TagTransController tagTransController = Get.find();
  final LocaleService localeService = Get.find();

  final EhSettingService ehSettingService = Get.find();
  bool get isTagTranslate =>
      ehSettingService.isTagTranslate && localeService.isLanguageCodeZh;

  final _searchText = ''.obs;
  String get searchText => _searchText.value;
  set searchText(String val) => _searchText.value = val;

  final resultList = <TagTranslat>[].obs;

  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    debounce(_searchText, (String val) async {
      // rultlist.clear();
      try {
        // 中文从翻译库匹配
        if (localeService.isLanguageCodeZh) {
          List<TagTranslat> tagTranslateList =
              await Get.find<TagTransController>()
                  .getTagTranslatesLike(text: val.trim(), limit: 100);
          // rultlist.addAll(tagTranslateList);
          resultList(tagTranslateList);
        } else {
          // 其它通过eh的api
          List<TagTranslat> tagTranslateList =
              await Api.tagSuggest(text: val.trim());
          // rultlist.addAll(tagTranslateList);
          resultList(tagTranslateList);
        }
      } catch (_) {}

      // tagTransController.getTagTranslatesLike(text: val.trim()).then((value) {
      //   rultlist.clear();
      //   rultlist.addAll(value);
      // });
    });
  }

  void selectItem(int index, {TextEditingController? searchTextController}) {
    final TagTranslat _qry = resultList[index];
    final String _add = _qry.key.contains(' ')
        ? '${_qry.namespace.trim().shortName}:"${_qry.key}\$"'
        : '${_qry.namespace.trim().shortName}:${_qry.key}\$';
    logger.d('_add $_add ');

    if (searchTextController != null) {
      searchTextController.value = TextEditingValue(
        text: _add,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _add.length)),
      );
    }
  }
}
