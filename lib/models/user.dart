import 'package:flutter/foundation.dart';


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
  final List<dynamic>? favcat;

  factory User.fromJson(Map<String,dynamic> json) => User(
    username: json['username'] != null ? json['username'] as String : null,
    cookie: json['cookie'] != null ? json['cookie'] as String : null,
    avatarUrl: json['avatarUrl'] != null ? json['avatarUrl'] as String : null,
    favcat: json['favcat'] != null ? (json['favcat'] as List? ?? []).map((e) => e as dynamic).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'cookie': cookie,
    'avatarUrl': avatarUrl,
    'favcat': favcat?.map((e) => e.toString()).toList()
  };

  User clone() => User(
    username: username,
    cookie: cookie,
    avatarUrl: avatarUrl,
    favcat: favcat?.toList()
  );

    
  User copyWith({
    String? username,
    String? cookie,
    String? avatarUrl,
    List<dynamic>? favcat
  }) => User(
    username: username ?? this.username,
    cookie: cookie ?? this.cookie,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    favcat: favcat ?? this.favcat,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is User && username == other.username && cookie == other.cookie && avatarUrl == other.avatarUrl && favcat == other.favcat;

  @override
  int get hashCode => username.hashCode ^ cookie.hashCode ^ avatarUrl.hashCode ^ favcat.hashCode;
}
