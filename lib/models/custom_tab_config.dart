import 'package:flutter/foundation.dart';
import 'custom_profile.dart';

@immutable
class CustomTabConfig {
  
  const CustomTabConfig({
    this.profiles,
  });

  final List<CustomProfile>? profiles;

  factory CustomTabConfig.fromJson(Map<String,dynamic> json) => CustomTabConfig(
    profiles: json['profiles'] != null ? (json['profiles'] as List? ?? []).map((e) => CustomProfile.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'profiles': profiles?.map((e) => e.toJson()).toList()
  };

  CustomTabConfig clone() => CustomTabConfig(
    profiles: profiles?.map((e) => e.clone()).toList()
  );

    
  CustomTabConfig copyWith({
    List<CustomProfile>? profiles
  }) => CustomTabConfig(
    profiles: profiles ?? this.profiles,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is CustomTabConfig && profiles == other.profiles;

  @override
  int get hashCode => profiles.hashCode;
}
