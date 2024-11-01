import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    this.yay,
    this.star,
    this.iq,
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
  final String? yay;
  final String? star;
  final String? iq;
  final String? avatarUrl;
  final List<Favcat>? favcat;
  final int? lastUptTime;

  factory User.fromJson(Map<String,dynamic> json) => User(
    username: json['username']?.toString(),
    nickName: json['nickName']?.toString(),
    memberId: json['memberId']?.toString(),
    passHash: json['passHash']?.toString(),
    igneous: json['igneous']?.toString(),
    hathPerks: json['hathPerks']?.toString(),
    sk: json['sk']?.toString(),
    yay: json['yay']?.toString(),
    star: json['star']?.toString(),
    iq: json['iq']?.toString(),
    avatarUrl: json['avatarUrl']?.toString(),
    favcat: json['favcat'] != null ? (json['favcat'] as List? ?? []).map((e) => Favcat.fromJson(e as Map<String, dynamic>)).toList() : null,
    lastUptTime: json['lastUptTime'] != null ? int.tryParse('${json['lastUptTime']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'nickName': nickName,
    'memberId': memberId,
    'passHash': passHash,
    'igneous': igneous,
    'hathPerks': hathPerks,
    'sk': sk,
    'yay': yay,
    'star': star,
    'iq': iq,
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
    yay: yay,
    star: star,
    iq: iq,
    avatarUrl: avatarUrl,
    favcat: favcat?.map((e) => e.clone()).toList(),
    lastUptTime: lastUptTime
  );


  User copyWith({
    Optional<String?>? username,
    Optional<String?>? nickName,
    Optional<String?>? memberId,
    Optional<String?>? passHash,
    Optional<String?>? igneous,
    Optional<String?>? hathPerks,
    Optional<String?>? sk,
    Optional<String?>? yay,
    Optional<String?>? star,
    Optional<String?>? iq,
    Optional<String?>? avatarUrl,
    Optional<List<Favcat>?>? favcat,
    Optional<int?>? lastUptTime
  }) => User(
    username: checkOptional(username, () => this.username),
    nickName: checkOptional(nickName, () => this.nickName),
    memberId: checkOptional(memberId, () => this.memberId),
    passHash: checkOptional(passHash, () => this.passHash),
    igneous: checkOptional(igneous, () => this.igneous),
    hathPerks: checkOptional(hathPerks, () => this.hathPerks),
    sk: checkOptional(sk, () => this.sk),
    yay: checkOptional(yay, () => this.yay),
    star: checkOptional(star, () => this.star),
    iq: checkOptional(iq, () => this.iq),
    avatarUrl: checkOptional(avatarUrl, () => this.avatarUrl),
    favcat: checkOptional(favcat, () => this.favcat),
    lastUptTime: checkOptional(lastUptTime, () => this.lastUptTime),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is User && username == other.username && nickName == other.nickName && memberId == other.memberId && passHash == other.passHash && igneous == other.igneous && hathPerks == other.hathPerks && sk == other.sk && yay == other.yay && star == other.star && iq == other.iq && avatarUrl == other.avatarUrl && favcat == other.favcat && lastUptTime == other.lastUptTime;

  @override
  int get hashCode => username.hashCode ^ nickName.hashCode ^ memberId.hashCode ^ passHash.hashCode ^ igneous.hashCode ^ hathPerks.hashCode ^ sk.hashCode ^ yay.hashCode ^ star.hashCode ^ iq.hashCode ^ avatarUrl.hashCode ^ favcat.hashCode ^ lastUptTime.hashCode;
}
