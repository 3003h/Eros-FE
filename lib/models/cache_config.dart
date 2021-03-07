import 'package:flutter/foundation.dart';


@immutable
class CacheConfig {
  
  const CacheConfig({
    this.enable,
    this.maxAge,
    this.maxCount,
  });

  final bool? enable;
  final int? maxAge;
  final int? maxCount;

  factory CacheConfig.fromJson(Map<String,dynamic> json) => CacheConfig(
    enable: json['enable'] != null ? json['enable'] as bool : null,
    maxAge: json['max_age'] != null ? json['max_age'] as int : null,
    maxCount: json['max_count'] != null ? json['max_count'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'enable': enable,
    'max_age': maxAge,
    'max_count': maxCount
  };

  CacheConfig clone() => CacheConfig(
    enable: enable,
    maxAge: maxAge,
    maxCount: maxCount
  );

    
  CacheConfig copyWith({
    bool? enable,
    int? maxAge,
    int? maxCount
  }) => CacheConfig(
    enable: enable ?? this.enable,
    maxAge: maxAge ?? this.maxAge,
    maxCount: maxCount ?? this.maxCount,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is CacheConfig && enable == other.enable && maxAge == other.maxAge && maxCount == other.maxCount;

  @override
  int get hashCode => enable.hashCode ^ maxAge.hashCode ^ maxCount.hashCode;
}
