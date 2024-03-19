import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class CustomTabConfig {

  const CustomTabConfig({
    this.profiles,
    this.lastIndex,
  });

  final List<CustomProfile>? profiles;
  final int? lastIndex;

  factory CustomTabConfig.fromJson(Map<String,dynamic> json) => CustomTabConfig(
    profiles: json['profiles'] != null ? (json['profiles'] as List? ?? []).map((e) => CustomProfile.fromJson(e as Map<String, dynamic>)).toList() : null,
    lastIndex: json['lastIndex'] != null ? int.tryParse('${json['lastIndex']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'profiles': profiles?.map((e) => e.toJson()).toList(),
    'lastIndex': lastIndex
  };

  CustomTabConfig clone() => CustomTabConfig(
    profiles: profiles?.map((e) => e.clone()).toList(),
    lastIndex: lastIndex
  );


  CustomTabConfig copyWith({
    Optional<List<CustomProfile>?>? profiles,
    Optional<int?>? lastIndex
  }) => CustomTabConfig(
    profiles: checkOptional(profiles, () => this.profiles),
    lastIndex: checkOptional(lastIndex, () => this.lastIndex),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is CustomTabConfig && profiles == other.profiles && lastIndex == other.lastIndex;

  @override
  int get hashCode => profiles.hashCode ^ lastIndex.hashCode;
}
