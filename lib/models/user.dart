import 'package:flutter/foundation.dart';
import 'favcat.dart';

@immutable
class User {
  
  const User({
    this.username,
    this.nickName,
    this.memberId,
    this.passHash,
    this.igneous,
    this.hathPerks,
    this.sk,
    this.avatarUrl,
    this.favcat,
    this.lastUptTime,
  });

  final String? username;
  final String? nickName;
  final String? memberId;
  final String? passHash;
  final String? igneous;
  final String? hathPerks;
  final String? sk;
  final String? avatarUrl;
  final List<Favcat>? favcat;
  final int? lastUptTime;

  factory User.fromJson(Map<String,dynamic> json) => User(
    username: json['username'] != null ? json['username'] as String : null,
    nickName: json['nickName'] != null ? json['nickName'] as String : null,
    memberId: json['memberId'] != null ? json['memberId'] as String : null,
    passHash: json['passHash'] != null ? json['passHash'] as String : null,
    igneous: json['igneous'] != null ? json['igneous'] as String : null,
    hathPerks: json['hathPerks'] != null ? json['hathPerks'] as String : null,
    sk: json['sk'] != null ? json['sk'] as String : null,
    avatarUrl: json['avatarUrl'] != null ? json['avatarUrl'] as String : null,
    favcat: json['favcat'] != null ? (json['favcat'] as List? ?? []).map((e) => Favcat.fromJson(e as Map<String, dynamic>)).toList() : null,
    lastUptTime: json['lastUptTime'] != null ? json['lastUptTime'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'nickName': nickName,
    'memberId': memberId,
    'passHash': passHash,
    'igneous': igneous,
    'hathPerks': hathPerks,
    'sk': sk,
    'avatarUrl': avatarUrl,
    'favcat': favcat?.map((e) => e.toJson()).toList(),
    'lastUptTime': lastUptTime
  };

  User clone() => User(
    username: username,
    nickName: nickName,
    memberId: memberId,
    passHash: passHash,
    igneous: igneous,
    hathPerks: hathPerks,
    sk: sk,
    avatarUrl: avatarUrl,
    favcat: favcat?.map((e) => e.clone()).toList(),
    lastUptTime: lastUptTime
  );

    
  User copyWith({
    String? username,
    String? nickName,
    String? memberId,
    String? passHash,
    String? igneous,
    String? hathPerks,
    String? sk,
    String? avatarUrl,
    List<Favcat>? favcat,
    int? lastUptTime
  }) => User(
    username: username ?? this.username,
    nickName: nickName ?? this.nickName,
    memberId: memberId ?? this.memberId,
    passHash: passHash ?? this.passHash,
    igneous: igneous ?? this.igneous,
    hathPerks: hathPerks ?? this.hathPerks,
    sk: sk ?? this.sk,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    favcat: favcat ?? this.favcat,
    lastUptTime: lastUptTime ?? this.lastUptTime,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is User && username == other.username && nickName == other.nickName && memberId == other.memberId && passHash == other.passHash && igneous == other.igneous && hathPerks == other.hathPerks && sk == other.sk && avatarUrl == other.avatarUrl && favcat == other.favcat && lastUptTime == other.lastUptTime;

  @override
  int get hashCode => username.hashCode ^ nickName.hashCode ^ memberId.hashCode ^ passHash.hashCode ^ igneous.hashCode ^ hathPerks.hashCode ^ sk.hashCode ^ avatarUrl.hashCode ^ favcat.hashCode ^ lastUptTime.hashCode;
}
