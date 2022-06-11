import 'package:flutter/foundation.dart';

import 'custom_profile.dart';

@immutable
class CustomTabConfig {
  const CustomTabConfig({
    this.profiles,
    this.lastIndex,
  });

  final List<CustomProfile>? profiles;
  final int? lastIndex;

  factory CustomTabConfig.fromJson(Map<String, dynamic> json) =>
      CustomTabConfig(
          profiles: json['profiles'] != null
              ? (json['profiles'] as List? ?? [])
                  .map((e) => CustomProfile.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
          lastIndex:
              json['lastIndex'] != null ? json['lastIndex'] as int : null);

  Map<String, dynamic> toJson() => {
        'profiles': profiles?.map((e) => e.toJson()).toList(),
        'lastIndex': lastIndex
      };

  CustomTabConfig clone() => CustomTabConfig(
      profiles: profiles?.map((e) => e.clone()).toList(), lastIndex: lastIndex);

  CustomTabConfig copyWith({List<CustomProfile>? profiles, int? lastIndex}) =>
      CustomTabConfig(
        profiles: profiles ?? this.profiles,
        lastIndex: lastIndex ?? this.lastIndex,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTabConfig &&
          profiles == other.profiles &&
          lastIndex == other.lastIndex;

  @override
  int get hashCode => profiles.hashCode ^ lastIndex.hashCode;
}
