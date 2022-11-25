import 'package:flutter/foundation.dart';


@immutable
class ItemConfig {
  
  const ItemConfig({
    required this.type,
    this.enableCustomWidth,
    this.customWidth,
  });

  final String type;
  final bool? enableCustomWidth;
  final int? customWidth;

  factory ItemConfig.fromJson(Map<String,dynamic> json) => ItemConfig(
    type: json['type'] as String,
    enableCustomWidth: json['enableCustomWidth'] != null ? json['enableCustomWidth'] as bool : null,
    customWidth: json['customWidth'] != null ? json['customWidth'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'enableCustomWidth': enableCustomWidth,
    'customWidth': customWidth
  };

  ItemConfig clone() => ItemConfig(
    type: type,
    enableCustomWidth: enableCustomWidth,
    customWidth: customWidth
  );

    
  ItemConfig copyWith({
    String? type,
    bool? enableCustomWidth,
    int? customWidth
  }) => ItemConfig(
    type: type ?? this.type,
    enableCustomWidth: enableCustomWidth ?? this.enableCustomWidth,
    customWidth: customWidth ?? this.customWidth,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is ItemConfig && type == other.type && enableCustomWidth == other.enableCustomWidth && customWidth == other.customWidth;

  @override
  int get hashCode => type.hashCode ^ enableCustomWidth.hashCode ^ customWidth.hashCode;
}
