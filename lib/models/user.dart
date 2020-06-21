import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User({this.username, this.cookie});

  String username;
  String cookie;

  @override
  String toString() {
    return 'User{username: $username, cookie: $cookie}';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
