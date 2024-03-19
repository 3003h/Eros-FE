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
    enable: json['enable'] != null ? bool.tryParse('${json['enable']}', caseSensitive: false) ?? false : null,
    maxAge: json['maxAge'] != null ? int.tryParse('${json['maxAge']}') ?? 0 : null,
    maxCount: json['maxCount'] != null ? int.tryParse('${json['maxCount']}') ?? 0 : null
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
