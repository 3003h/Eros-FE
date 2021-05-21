import 'package:flutter/foundation.dart';

import 'favcat.dart';

@immutable
class User {
  const User({
    this.username,
    this.cookie,
    this.avatarUrl,
    this.favcat,
  });

  final String? username;
  final String? cookie;
  final String? avatarUrl;
  final List<Favcat>? favcat;

  factory User.fromJson(Map<String, dynamic> json) => User(
      username: json['username'] != null ? json['username'] as String : null,
      cookie: json['cookie'] != null ? json['cookie'] as String : null,
      avatarUrl: json['avatarUrl'] != null ? json['avatarUrl'] as String : null,
      favcat: json['favcat'] != null
          ? (json['favcat'] as List? ?? [])
              .map((e) => Favcat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'username': username,
        'cookie': cookie,
        'avatarUrl': avatarUrl,
        'favcat': favcat?.map((e) => e.toJson()).toList()
      };

  User clone() => User(
      username: username,
      cookie: cookie,
      avatarUrl: avatarUrl,
      favcat: favcat?.map((e) => e.clone()).toList());

  User copyWith(
          {String? username,
          String? cookie,
          String? avatarUrl,
          List<Favcat>? favcat}) =>
      User(
        username: username ?? this.username,
        cookie: cookie ?? this.cookie,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        favcat: favcat ?? this.favcat,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          username == other.username &&
          cookie == other.cookie &&
          avatarUrl == other.avatarUrl &&
          favcat == other.favcat;

  @override
  int get hashCode =>
      username.hashCode ^
      cookie.hashCode ^
      avatarUrl.hashCode ^
      favcat.hashCode;
}
