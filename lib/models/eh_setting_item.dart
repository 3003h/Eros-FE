import 'package:flutter/foundation.dart';


@immutable
class EhSettingItem {
  
  const EhSettingItem({
    this.type,
    this.ser,
    this.value,
    this.name,
  });

  final String? type;
  final String? ser;
  final String? value;
  final String? name;

  factory EhSettingItem.fromJson(Map<String,dynamic> json) => EhSettingItem(
    type: json['type'] != null ? json['type'] as String : null,
    ser: json['ser'] != null ? json['ser'] as String : null,
    value: json['value'] != null ? json['value'] as String : null,
    name: json['name'] != null ? json['name'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'ser': ser,
    'value': value,
    'name': name
  };

  EhSettingItem clone() => EhSettingItem(
    type: type,
    ser: ser,
    value: value,
    name: name
  );

    
  EhSettingItem copyWith({
    String? type,
    String? ser,
    String? value,
    String? name
  }) => EhSettingItem(
    type: type ?? this.type,
    ser: ser ?? this.ser,
    value: value ?? this.value,
    name: name ?? this.name,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhSettingItem && type == other.type && ser == other.ser && value == other.value && name == other.name;

  @override
  int get hashCode => type.hashCode ^ ser.hashCode ^ value.hashCode ^ name.hashCode;
}
