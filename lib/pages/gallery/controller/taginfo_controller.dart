import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/toast.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

class TagInfoController extends GetxController {
  TagInfoController();
  late GalleryPageController pageController;
  GalleryPageState get _pageState => pageController.gState;
  GalleryProvider? get _item => _pageState.galleryProvider;

  final TextEditingController tagsTextController = TextEditingController();
  FocusNode focusNode = FocusNode();

  String get tags => tagsTextController.text;
  late DateTime _lastInputCompleteAt; //上次输入完成时间
  String _lastSearchText = '';
  final RxList<TagTranslat> qryTags = <TagTranslat>[].obs;
  late String currQry;

  bool get showClearButton => tagsTextController.text.isNotEmpty;

  final EhSettingService _ehSettingService = Get.find();
  bool get isTagTranslat => _ehSettingService.isTagTranslate;

  @override
  void onInit() {
    super.onInit();
    pageController = Get.find(tag: pageCtrlTag);
    tagsTextController.addListener(_delayedSearch);
  }

  /// 延迟搜索
  Future<void> _delayedSearch() async {
    update([GetIds.TAG_ADD_CLEAR_BTN]);
    logger.d(' _delayedSearch');
    const Duration _duration = Duration(milliseconds: 800);
    _lastInputCompleteAt = DateTime.now();
    await Future<void>.delayed(_duration);
    if (_lastSearchText.trim() != tagsTextController.text.trim() &&
        DateTime.now().difference(_lastInputCompleteAt) >= _duration) {
      _lastSearchText = tagsTextController.text.trim();

      currQry = tagsTextController.text.trim().split(RegExp(r'[ ,;"]')).last;
      if (currQry.isEmpty) {
        qryTags([]);
        return;
      }

      /*try {
        dbUtil
            .getTagTransFuzzy(_currQry, limit: 200)
            .then((List<TagTranslat>? qryTags) {
          // ignore: unnecessary_string_interpolations
          // logger.d('${qryTags.map((TagTranslat e) => e.name).join('\n')}');
          this.qryTags(qryTags);
        });
      } catch (_) {}*/

      try {
        Get.find<TagTransController>()
            .getTagTranslatesLike(text: currQry, limit: 200)
            .then((List<TagTranslat> value) => qryTags(value));
      } catch (_) {}
    }
  }

  void addQryTag(int index) {
    final TagTranslat _qry = qryTags[index];
    final String _add = _qry.key.contains(' ')
        ? '${_qry.namespace.trim().shortName}:"${_qry.key}\$"'
        : '${_qry.namespace.trim().shortName}:${_qry.key}\$';
    logger.d('_add $_add ');

    final String _lastSearchText = this._lastSearchText;
    final String _newSearch =
        _lastSearchText.replaceAll(RegExp('$currQry\$'), _add);
    logger.d(
        '_lastSearchText $_lastSearchText \n_currQry $currQry\n_newSearch $_newSearch ');

    tagsTextController.value = TextEditingValue(
      text: '$_newSearch, ',
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: '$_newSearch, '.length)),
    );

    FocusScope.of(Get.context!).requestFocus(focusNode);
  }

  Future<void> tagVoteDown(String tags) async {
    if (_item == null) {
      return;
    }
    logger.d('tags down id $tags');

    final Map<String, dynamic> rult = await Api.tagGallery(
      apikey: _item!.apikey!,
      apiuid: _item!.apiuid!,
      gid: _item!.gid!,
      token: _item!.token!,
      tags: tags,
      vote: -1,
    );
    final errorInfo = rult['error'];
    if (errorInfo != null) {
      showToast('$errorInfo');
    } else {
      showToast(L10n.of(Get.context!).vote_successfully);
    }
  }

  Future<void> tagVoteUp(String tags) async {
    if (_item == null) {
      return;
    }
    logger.d('tags down id $tags');

    final Map<String, dynamic> rult = await Api.tagGallery(
      apikey: _item!.apikey!,
      apiuid: _item!.apiuid!,
      gid: _item!.gid!,
      token: _item!.token!,
      tags: tags,
      vote: 1,
    );
    final errorInfo = rult['error'];
    if (errorInfo != null) {
      showToast('$errorInfo');
    } else {
      showToast(L10n.of(Get.context!).vote_successfully);
    }
  }

  void clear() {
    vibrateUtil.light();
    tagsTextController.clear();
  }
}
