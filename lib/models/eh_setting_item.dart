import 'package:flutter/foundation.dart';


@immutable
class EhSettingItem {
  
  const EhSettingItem({
    this.name,
    this.ser,
    this.value,
  });

  final String? name;
  final String? ser;
  final String? value;

  factory EhSettingItem.fromJson(Map<String,dynamic> json) => EhSettingItem(
    name: json['name'] != null ? json['name'] as String : null,
    ser: json['ser'] != null ? json['ser'] as String : null,
    value: json['value'] != null ? json['value'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'ser': ser,
    'value': value
  };

  EhSettingItem clone() => EhSettingItem(
    name: name,
    ser: ser,
    value: value
  );

    
  EhSettingItem copyWith({
    String? name,
    String? ser,
    String? value
  }) => EhSettingItem(
    name: name ?? this.name,
    ser: ser ?? this.ser,
    value: value ?? this.value,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhSettingItem && name == other.name && ser == other.ser && value == other.value;

  @override
  int get hashCode => name.hashCode ^ ser.hashCode ^ value.hashCode;
}
