import 'package:json_annotation/json_annotation.dart';

import "cacheConfig.dart";
import "ehConfig.dart";
import "user.dart";

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  User user;
  String token;
  CacheConfig cache;
  EhConfig ehConfig;
  String lastLogin;
  String locale;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
