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
}

extension ExtTabList on TabConfig {
  Map<String, bool> get tabMap {
    final Map<String, bool> _map = <String, bool>{};
    for (final TabItem item in tabItemList) {
      _map[item.name] = item.enable;
    }
    return _map;
  }

  List<String> get tabNameList {
    return tabItemList.map((e) => e.name).toList();
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
        return e?.text ?? '';
      }).join();
}

extension ExtCommentSpan on GalleryCommentSpan {
  CommentSpanType get sType =>
      EnumToString.fromString(CommentSpanType.values, type ?? '') ??
      CommentSpanType.text;
  // set sType(CommentSpanType val) => type = EnumToString.convertToString(val);
}

extension ExtItem on GalleryItem {
  Map<int, GalleryPreview> get previewMap =>
      {for (GalleryPreview v in galleryPreview) v.ser: v};
}
