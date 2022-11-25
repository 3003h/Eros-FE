import 'package:flutter/foundation.dart';


@immutable
class ListItemConfig {
  
  const ListItemConfig({
    required this.type,
    required this.enableCustomWidth,
    required this.customWidth,
  });

  final String type;
  final bool enableCustomWidth;
  final int customWidth;

  factory ListItemConfig.fromJson(Map<String,dynamic> json) => ListItemConfig(
    type: json['type'] as String,
    enableCustomWidth: json['enableCustomWidth'] as bool,
    customWidth: json['customWidth'] as int
  );
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'enableCustomWidth': enableCustomWidth,
    'customWidth': customWidth
  };

  ListItemConfig clone() => ListItemConfig(
    type: type,
    enableCustomWidth: enableCustomWidth,
    customWidth: customWidth
  );

    
  ListItemConfig copyWith({
    String? type,
    bool? enableCustomWidth,
    int? customWidth
  }) => ListItemConfig(
    type: type ?? this.type,
    enableCustomWidth: enableCustomWidth ?? this.enableCustomWidth,
    customWidth: customWidth ?? this.customWidth,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is ListItemConfig && type == other.type && enableCustomWidth == other.enableCustomWidth && customWidth == other.customWidth;

  @override
  int get hashCode => type.hashCode ^ enableCustomWidth.hashCode ^ customWidth.hashCode;
}
