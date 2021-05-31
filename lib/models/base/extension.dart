import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/image_view/controller/view_state.dart';

import '../index.dart';

extension ExtGC on GalleryCache {
  ViewColumnMode get columnMode =>
      EnumToString.fromString(ViewColumnMode.values, columnModeVal ?? '') ??
      ViewColumnMode.single;

  // set columnMode(ViewColumnMode val) =>
  //     columnModeVal = EnumToString.convertToString(val);
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
