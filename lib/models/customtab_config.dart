import 'package:flutter/foundation.dart';

import 'custom_profile.dart';

@immutable
class CustomtabConfig {
  const CustomtabConfig({
    this.profiles,
  });

  final List<CustomProfile>? profiles;

  factory CustomtabConfig.fromJson(Map<String, dynamic> json) =>
      CustomtabConfig(
          profiles: json['profiles'] != null
              ? (json['profiles'] as List? ?? [])
                  .map((e) => CustomProfile.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null);

  Map<String, dynamic> toJson() =>
      {'profiles': profiles?.map((e) => e.toJson()).toList()};

  CustomtabConfig clone() =>
      CustomtabConfig(profiles: profiles?.map((e) => e.clone()).toList());

  CustomtabConfig copyWith({List<CustomProfile>? profiles}) => CustomtabConfig(
        profiles: profiles ?? this.profiles,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomtabConfig && profiles == other.profiles;

  @override
  int get hashCode => profiles.hashCode;
}
