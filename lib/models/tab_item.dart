import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class TabItem {

  const TabItem({
    required this.name,
    this.enable,
  });

  final String name;
  final bool? enable;

  factory TabItem.fromJson(Map<String,dynamic> json) => TabItem(
    name: json['name'].toString(),
    enable: json['enable'] != null ? bool.tryParse('${json['enable']}', caseSensitive: false) ?? false : null
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'enable': enable
  };

  TabItem clone() => TabItem(
    name: name,
    enable: enable
  );


  TabItem copyWith({
    String? name,
    Optional<bool?>? enable
  }) => TabItem(
    name: name ?? this.name,
    enable: checkOptional(enable, () => this.enable),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is TabItem && name == other.name && enable == other.enable;

  @override
  int get hashCode => name.hashCode ^ enable.hashCode;
}
