import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/image_view/controller/view_state.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

import '../index.dart';

extension ExtGC on GalleryCache {
  ViewColumnMode get columnMode =>
      EnumToString.fromString(ViewColumnMode.values, columnModeVal ?? '') ??
      ViewColumnMode.single;

  GalleryCache copyWithMode(ViewColumnMode val) =>
      copyWith(columnModeVal: EnumToString.convertToString(val));
}

extension ExtTabList on TabConfig {
  Map<String, bool> get tabMap {
    final Map<String, bool> _map = <String, bool>{};
    for (final TabItem item in tabItemList) {
      _map[item.name] = item.enable ?? false;
    }
    return _map;
  }

  List<String> get tabNameList {
    return tabItemList.map((TabItem e) => e.name).toList();
  }

  void setItemList(Map<String, bool> map, List<String> nameList) {
    tabItemList.clear();
    for (final String name in nameList) {
      tabItemList.add(TabItem(name: name, enable: map[name] ?? false));
    }
  }
}

extension ExtComment on GalleryComment {
  // 提取评论纯文字部分内容
  String get text => span.map((GalleryCommentSpan e) {
        if (e.imageUrl?.isNotEmpty ?? false) {
          return '[image]${e.href ?? ''} ';
        }
        return e.text ?? '';
      }).join();

  String get textTranslate => span.map((GalleryCommentSpan e) {
        if (e.imageUrl?.isNotEmpty ?? false) {
          return '[image]${e.href ?? ''} ';
        }
        return e.translate ?? '';
      }).join();
}

extension ExtCommentSpan on GalleryCommentSpan {
  CommentSpanType get sType =>
      EnumToString.fromString(CommentSpanType.values, type ?? '') ??
      CommentSpanType.text;

  // set sType(CommentSpanType val) => type = EnumToString.convertToString(val);
  GalleryCommentSpan copyWithSpanType(CommentSpanType val) =>
      copyWith(type: EnumToString.convertToString(val));
}

extension ExtItem on GalleryItem {
  Map<int, GalleryPreview> get previewMap =>
      {for (GalleryPreview v in galleryPreview ?? []) v.ser: v};
}

extension ExtUser on User {
  List<String> get _cookieStrList => cookie?.split(';') ?? [];
  List<Cookie> get _cookies =>
      _cookieStrList.map((e) => Cookie.fromSetCookieValue(e)).toList();

  String get memberIdFromCookie => _cookies
      .where((Cookie element) => element.name == 'ipb_member_id')
      .first
      .value;

  String get passHashFromCookie => _cookies
      .where((Cookie element) => element.name == 'ipb_pass_hash')
      .first
      .value;

  String get igneousFromCookie =>
      _cookies.where((Cookie element) => element.name == 'igneous').first.value;

  String get memberIdFB => memberId ?? memberIdFromCookie;

  String get passHashFB => passHash ?? passHashFromCookie;

  String get igneousFB => igneous ?? igneousFromCookie;
}

extension ExtTagTranlat on TagTranslat {
  String? get nameNotMD {
    final reg = RegExp(r'!\[\S+\]\(.+?\)(\S+)');
    final match = reg.allMatches(name ?? '');
    if (match.isNotEmpty) {
      return name?.replaceAllMapped(reg, (match) => match.group(1) ?? '') ??
          name;
    } else {
      return name;
    }
  }

  String? get introMDimage {
    final EhConfigService ehConfigService = Get.find();

    // 匹配R18g
    final regR18g = RegExp(r'!\[((\S+)?)\]\(##\s+?"(.+?)"\)');

    // 匹配R18和R18g
    final regR18And18g = RegExp(r'!\[((\S+)?)\]\(##?\s+?"(.+?)"\)');

    // 匹配所有级别图片
    final regAll = RegExp(r'!\[((\S+)?)\]\((.+?)\)');

    final lv = ehConfigService.tagIntroImgLv.value;

    String? _remove(RegExp regExp, String? text) {
      final match = regExp.allMatches(text ?? '');
      if (match.isNotEmpty) {
        final rult = text?.replaceAllMapped(regExp, (match) => '') ?? text;
        logger.v(rult);
        return rult;
      } else {
        return text;
      }
    }

    String? _fix(RegExp regExp, String? text) {
      final match = regExp.allMatches(text ?? '');
      if (match.isNotEmpty) {
        final rult = text?.replaceAllMapped(
                regExp, (match) => '![${match.group(2)}](${match.group(3)})') ??
            text;
        logger.v(rult);
        return rult;
      } else {
        return text;
      }
    }

    logger.d(lv);
    switch (lv) {
      case TagIntroImgLv.disable:
        // 去除所有
        return _remove(regAll, intro);
      case TagIntroImgLv.nonh:
        // 去除R18和r18g
        return _remove(regR18And18g, intro);
      case TagIntroImgLv.r18:
        // 去除R18g, 把r18的格式修正
        return _fix(regR18And18g, _remove(regR18g, intro));
        break;
      case TagIntroImgLv.r18g:
        // 把r18和r18g的格式修正
        return _fix(regR18And18g, intro);
    }
  }
}

extension ExtString on String {}
