import 'package:flutter/foundation.dart';
import 'item_config.dart';

@immutable
class LayoutConfig {
  
  const LayoutConfig({
    this.itemConfigs,
  });

  final List<ItemConfig>? itemConfigs;

  factory LayoutConfig.fromJson(Map<String,dynamic> json) => LayoutConfig(
    itemConfigs: json['item_configs'] != null ? (json['item_configs'] as List? ?? []).map((e) => ItemConfig.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'item_configs': itemConfigs?.map((e) => e.toJson()).toList()
  };

  LayoutConfig clone() => LayoutConfig(
    itemConfigs: itemConfigs?.map((e) => e.clone()).toList()
  );

    
  LayoutConfig copyWith({
    List<ItemConfig>? itemConfigs
  }) => LayoutConfig(
    itemConfigs: itemConfigs ?? this.itemConfigs,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is LayoutConfig && itemConfigs == other.itemConfigs;

  @override
  int get hashCode => itemConfigs.hashCode;
}
