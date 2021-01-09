import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';

import '../index.dart';

extension ExtGC on GalleryCache {
  ColumnMode get columnMode =>
      EnumToString.fromString(ColumnMode.values, columnModeVal);
  set columnMode(ColumnMode val) =>
      columnModeVal = EnumToString.convertToString(val);
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

  // set tabMap(Map<String, bool> map) {
  //   tabItemList.clear();
  //   for (MapEntry<String, bool> element in map.entries) {
  //     tabItemList.add(TabItem()
  //       ..name = element.key
  //       ..enable = element.value);
  //   }
  // }

  void setItemList(Map<String, bool> map, List<String> nameList) {
    tabItemList.clear();
    for (final String name in nameList) {
      tabItemList.add(TabItem()
        ..name = name
        ..enable = map[name] ?? false);
    }
  }
}
