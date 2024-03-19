import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class EhMytagSet {

  const EhMytagSet({
    required this.name,
    this.tagCount,
    this.enable,
    this.value,
  });

  final String name;
  final String? tagCount;
  final bool? enable;
  final String? value;

  factory EhMytagSet.fromJson(Map<String,dynamic> json) => EhMytagSet(
    name: json['name'].toString(),
    tagCount: json['tagCount']?.toString(),
    enable: json['enable'] != null ? bool.tryParse('${json['enable']}', caseSensitive: false) ?? false : null,
    value: json['value']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'tagCount': tagCount,
    'enable': enable,
    'value': value
  };

  EhMytagSet clone() => EhMytagSet(
    name: name,
    tagCount: tagCount,
    enable: enable,
    value: value
  );


  EhMytagSet copyWith({
    String? name,
    Optional<String?>? tagCount,
    Optional<bool?>? enable,
    Optional<String?>? value
  }) => EhMytagSet(
    name: name ?? this.name,
    tagCount: checkOptional(tagCount, () => this.tagCount),
    enable: checkOptional(enable, () => this.enable),
    value: checkOptional(value, () => this.value),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is EhMytagSet && name == other.name && tagCount == other.tagCount && enable == other.enable && value == other.value;

  @override
  int get hashCode => name.hashCode ^ tagCount.hashCode ^ enable.hashCode ^ value.hashCode;
}
