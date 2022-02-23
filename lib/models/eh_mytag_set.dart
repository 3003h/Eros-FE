import 'package:flutter/foundation.dart';


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
    name: json['name'] as String,
    tagCount: json['tagCount'] != null ? json['tagCount'] as String : null,
    enable: json['enable'] != null ? json['enable'] as bool : null,
    value: json['value'] != null ? json['value'] as String : null
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
    String? tagCount,
    bool? enable,
    String? value
  }) => EhMytagSet(
    name: name ?? this.name,
    tagCount: tagCount ?? this.tagCount,
    enable: enable ?? this.enable,
    value: value ?? this.value,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhMytagSet && name == other.name && tagCount == other.tagCount && enable == other.enable && value == other.value;

  @override
  int get hashCode => name.hashCode ^ tagCount.hashCode ^ enable.hashCode ^ value.hashCode;
}
