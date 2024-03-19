import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    maxAge: json['maxAge'] != null ? json['maxAge'] as int : null,
    maxCount: json['maxCount'] != null ? json['maxCount'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'enable': enable,
    'maxAge': maxAge,
    'maxCount': maxCount
  };

  CacheConfig clone() => CacheConfig(
    enable: enable,
    maxAge: maxAge,
    maxCount: maxCount
  );


  CacheConfig copyWith({
    Optional<bool?>? enable,
    Optional<int?>? maxAge,
    Optional<int?>? maxCount
  }) => CacheConfig(
    enable: checkOptional(enable, () => this.enable),
    maxAge: checkOptional(maxAge, () => this.maxAge),
    maxCount: checkOptional(maxCount, () => this.maxCount),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is CacheConfig && enable == other.enable && maxAge == other.maxAge && maxCount == other.maxCount;

  @override
  int get hashCode => enable.hashCode ^ maxAge.hashCode ^ maxCount.hashCode;
}
