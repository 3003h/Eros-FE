import 'package:flutter/foundation.dart';


@immutable
class WebdavProfile {
  
  const WebdavProfile({
    required this.url,
    this.user,
    this.password,
    this.syncHistory,
    this.syncReadProgress,
  });

  final String url;
  final String? user;
  final String? password;
  final bool? syncHistory;
  final bool? syncReadProgress;

  factory WebdavProfile.fromJson(Map<String,dynamic> json) => WebdavProfile(
    url: json['url'] as String,
    user: json['user'] != null ? json['user'] as String : null,
    password: json['password'] != null ? json['password'] as String : null,
    syncHistory: json['syncHistory'] != null ? json['syncHistory'] as bool : null,
    syncReadProgress: json['syncReadProgress'] != null ? json['syncReadProgress'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'url': url,
    'user': user,
    'password': password,
    'syncHistory': syncHistory,
    'syncReadProgress': syncReadProgress
  };

  WebdavProfile clone() => WebdavProfile(
    url: url,
    user: user,
    password: password,
    syncHistory: syncHistory,
    syncReadProgress: syncReadProgress
  );

    
  WebdavProfile copyWith({
    String? url,
    String? user,
    String? password,
    bool? syncHistory,
    bool? syncReadProgress
  }) => WebdavProfile(
    url: url ?? this.url,
    user: user ?? this.user,
    password: password ?? this.password,
    syncHistory: syncHistory ?? this.syncHistory,
    syncReadProgress: syncReadProgress ?? this.syncReadProgress,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is WebdavProfile && url == other.url && user == other.user && password == other.password && syncHistory == other.syncHistory && syncReadProgress == other.syncReadProgress;

  @override
  int get hashCode => url.hashCode ^ user.hashCode ^ password.hashCode ^ syncHistory.hashCode ^ syncReadProgress.hashCode;
}
