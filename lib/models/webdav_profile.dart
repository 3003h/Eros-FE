import 'package:flutter/foundation.dart';


@immutable
class WebdavProfile {
  
  const WebdavProfile({
    required this.url,
    this.user,
    this.password,
    this.syncHistory,
  });

  final String url;
  final String? user;
  final String? password;
  final bool? syncHistory;

  factory WebdavProfile.fromJson(Map<String,dynamic> json) => WebdavProfile(
    url: json['url'] as String,
    user: json['user'] != null ? json['user'] as String : null,
    password: json['password'] != null ? json['password'] as String : null,
    syncHistory: json['syncHistory'] != null ? json['syncHistory'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'url': url,
    'user': user,
    'password': password,
    'syncHistory': syncHistory
  };

  WebdavProfile clone() => WebdavProfile(
    url: url,
    user: user,
    password: password,
    syncHistory: syncHistory
  );

    
  WebdavProfile copyWith({
    String? url,
    String? user,
    String? password,
    bool? syncHistory
  }) => WebdavProfile(
    url: url ?? this.url,
    user: user ?? this.user,
    password: password ?? this.password,
    syncHistory: syncHistory ?? this.syncHistory,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is WebdavProfile && url == other.url && user == other.user && password == other.password && syncHistory == other.syncHistory;

  @override
  int get hashCode => url.hashCode ^ user.hashCode ^ password.hashCode ^ syncHistory.hashCode;
}
