// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User()
    ..username = json['username'] as String
    ..cookie = json['cookie'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) =>
    <String, dynamic>{'username': instance.username, 'cookie': instance.cookie};
