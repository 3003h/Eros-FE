import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class WebdavProfile {

  const WebdavProfile({
    required this.url,
    this.user,
    this.password,
    this.syncHistory,
    this.syncReadProgress,
    this.syncGroupProfile,
    this.syncQuickSearch,
  });

  final String url;
  final String? user;
  final String? password;
  final bool? syncHistory;
  final bool? syncReadProgress;
  final bool? syncGroupProfile;
  final bool? syncQuickSearch;

  factory WebdavProfile.fromJson(Map<String,dynamic> json) => WebdavProfile(
    url: json['url'].toString(),
    user: json['user']?.toString(),
    password: json['password']?.toString(),
    syncHistory: json['syncHistory'] != null ? bool.tryParse('${json['syncHistory']}', caseSensitive: false) ?? false : null,
    syncReadProgress: json['syncReadProgress'] != null ? bool.tryParse('${json['syncReadProgress']}', caseSensitive: false) ?? false : null,
    syncGroupProfile: json['syncGroupProfile'] != null ? bool.tryParse('${json['syncGroupProfile']}', caseSensitive: false) ?? false : null,
    syncQuickSearch: json['syncQuickSearch'] != null ? bool.tryParse('${json['syncQuickSearch']}', caseSensitive: false) ?? false : null
  );
  
  Map<String, dynamic> toJson() => {
    'url': url,
    'user': user,
    'password': password,
    'syncHistory': syncHistory,
    'syncReadProgress': syncReadProgress,
    'syncGroupProfile': syncGroupProfile,
    'syncQuickSearch': syncQuickSearch
  };

  WebdavProfile clone() => WebdavProfile(
    url: url,
    user: user,
    password: password,
    syncHistory: syncHistory,
    syncReadProgress: syncReadProgress,
    syncGroupProfile: syncGroupProfile,
    syncQuickSearch: syncQuickSearch
  );


  WebdavProfile copyWith({
    String? url,
    Optional<String?>? user,
    Optional<String?>? password,
    Optional<bool?>? syncHistory,
    Optional<bool?>? syncReadProgress,
    Optional<bool?>? syncGroupProfile,
    Optional<bool?>? syncQuickSearch
  }) => WebdavProfile(
    url: url ?? this.url,
    user: checkOptional(user, () => this.user),
    password: checkOptional(password, () => this.password),
    syncHistory: checkOptional(syncHistory, () => this.syncHistory),
    syncReadProgress: checkOptional(syncReadProgress, () => this.syncReadProgress),
    syncGroupProfile: checkOptional(syncGroupProfile, () => this.syncGroupProfile),
    syncQuickSearch: checkOptional(syncQuickSearch, () => this.syncQuickSearch),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is WebdavProfile && url == other.url && user == other.user && password == other.password && syncHistory == other.syncHistory && syncReadProgress == other.syncReadProgress && syncGroupProfile == other.syncGroupProfile && syncQuickSearch == other.syncQuickSearch;

  @override
  int get hashCode => url.hashCode ^ user.hashCode ^ password.hashCode ^ syncHistory.hashCode ^ syncReadProgress.hashCode ^ syncGroupProfile.hashCode ^ syncQuickSearch.hashCode;
}
