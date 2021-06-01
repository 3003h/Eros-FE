import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class TagInfoController extends GetxController {
  GalleryPageController get pageController => Get.find(tag: pageCtrlDepth);

  GalleryItem get _item => pageController.galleryItem;

  final TextEditingController tagsTextController = TextEditingController();
  FocusNode focusNode = FocusNode();

  String get tags => tagsTextController.text;
  late DateTime _lastInputCompleteAt; //上次输入完成时间
  String _lastSearchText = '';
  final RxList<TagTranslat> qryTags = <TagTranslat>[].obs;
  late String _currQry;

  bool get showClearButton => tagsTextController.text.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
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

      _currQry = tagsTextController.text.trim().split(RegExp(r'[ ,;"]')).last;
      if (_currQry.isEmpty) {
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
            .getTagTranslatesLike(text: _currQry, limit: 200)
            .then((List<TagTranslat> value) => qryTags(value));
      } catch (_) {}
    }
  }

  void addQryTag(int index) {
    final TagTranslat _qry = qryTags[index];
    final String _add = _qry.key.contains(' ')
        ? '${_qry.namespace.trim().shortName}:"${_qry.key}\$"'
        : '${_qry.namespace.trim().shortName}:${_qry.key}\$';
    logger.i('_add $_add ');

    final String _lastSearchText = this._lastSearchText;
    final String _newSearch =
        _lastSearchText.replaceAll(RegExp('$_currQry\$'), _add);
    logger.i(
        '_lastSearchText $_lastSearchText \n_currQry $_currQry\n_newSearch $_newSearch ');

    tagsTextController.value = TextEditingValue(
      text: '$_newSearch, ',
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: '$_newSearch, '.length)),
    );

    FocusScope.of(Get.context!).requestFocus(focusNode);
  }

  Future<void> tagVoteDown(String tags) async {
    logger.d('tags down id $tags');

    final Map<String, dynamic> rult = await Api.tagGallery(
      apikey: _item.apikey!,
      apiuid: _item.apiuid!,
      gid: _item.gid!,
      token: _item.token!,
      tags: tags,
      vote: -1,
    );
    final errorInfo = rult['error'];
    if (errorInfo != null) {
      showToast('$errorInfo');
    } else {
      showToast(S.of(Get.context!).vote_successfully);
    }
  }

  Future<void> tagVoteUp(String tags) async {
    logger.d('tags down id $tags');

    final Map<String, dynamic> rult = await Api.tagGallery(
      apikey: _item.apikey!,
      apiuid: _item.apiuid!,
      gid: _item.gid!,
      token: _item.token!,
      tags: tags,
      vote: 1,
    );
    final errorInfo = rult['error'];
    if (errorInfo != null) {
      showToast('$errorInfo');
    } else {
      showToast(S.of(Get.context!).vote_successfully);
    }
  }

  void clear() {
    vibrateUtil.light();
    tagsTextController.clear();
  }
}

extension ExSearch on String {
  String get shortName {
    if (this != 'misc') {
      return substring(0, 1);
    } else {
      return this;
    }
  }
}
