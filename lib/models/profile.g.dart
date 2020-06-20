// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile()
    ..user = json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>)
    ..token = json['token'] as String
    ..cache = json['cache'] == null
        ? null
        : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>)
    ..ehConfig = json['ehConfig'] == null
        ? null
        : EhConfig.fromJson(json['ehConfig'] as Map<String, dynamic>)
    ..lastLogin = json['lastLogin'] as String
    ..locale = json['locale'] as String;
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'cache': instance.cache,
      'ehConfig': instance.ehConfig,
      'lastLogin': instance.lastLogin,
      'locale': instance.locale
    };
