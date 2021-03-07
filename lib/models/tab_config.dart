import 'package:flutter/foundation.dart';

import 'tab_item.dart';

@immutable
class TabConfig {
  const TabConfig({
    required this.tabItemList,
  });

  final List<TabItem> tabItemList;

  factory TabConfig.fromJson(Map<String, dynamic> json) => TabConfig(
      tabItemList: (json['tab_item_list'] as List)
          .map((e) => TabItem.fromJson(e as Map<String, dynamic>))
          .toList());

  Map<String, dynamic> toJson() =>
      {'tab_item_list': tabItemList.map((e) => e.toJson()).toList()};

  TabConfig clone() =>
      TabConfig(tabItemList: tabItemList.map((e) => e.clone()).toList());

  TabConfig copyWith({List<TabItem>? tabItemList}) => TabConfig(
        tabItemList: tabItemList ?? this.tabItemList,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabConfig && tabItemList == other.tabItemList;

  @override
  int get hashCode => tabItemList.hashCode;
}
