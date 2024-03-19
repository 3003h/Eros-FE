import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    type: json['type']?.toString(),
    ser: json['ser']?.toString(),
    value: json['value']?.toString(),
    name: json['name']?.toString()
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
    Optional<String?>? type,
    Optional<String?>? ser,
    Optional<String?>? value,
    Optional<String?>? name
  }) => EhSettingItem(
    type: checkOptional(type, () => this.type),
    ser: checkOptional(ser, () => this.ser),
    value: checkOptional(value, () => this.value),
    name: checkOptional(name, () => this.name),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is EhSettingItem && type == other.type && ser == other.ser && value == other.value && name == other.name;

  @override
  int get hashCode => type.hashCode ^ ser.hashCode ^ value.hashCode ^ name.hashCode;
}
