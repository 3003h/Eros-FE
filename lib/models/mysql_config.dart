import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class MysqlConfig {

  const MysqlConfig({
    this.syncHistory,
    this.syncReadProgress,
    this.syncGroupProfile,
    this.syncQuickSearch,
    this.isValidAccount,
    this.mysqlConnectionInfo,
  });

  final bool? syncHistory;
  final bool? syncReadProgress;
  final bool? syncGroupProfile;
  final bool? syncQuickSearch;
  final bool? isValidAccount;
  final MysqlConnectionInfo? mysqlConnectionInfo;

  factory MysqlConfig.fromJson(Map<String,dynamic> json) => MysqlConfig(
    syncHistory: json['syncHistory'] != null ? bool.tryParse('${json['syncHistory']}', caseSensitive: false) ?? false : null,
    syncReadProgress: json['syncReadProgress'] != null ? bool.tryParse('${json['syncReadProgress']}', caseSensitive: false) ?? false : null,
    syncGroupProfile: json['syncGroupProfile'] != null ? bool.tryParse('${json['syncGroupProfile']}', caseSensitive: false) ?? false : null,
    syncQuickSearch: json['syncQuickSearch'] != null ? bool.tryParse('${json['syncQuickSearch']}', caseSensitive: false) ?? false : null,
    isValidAccount: json['isValidAccount'] != null ? bool.tryParse('${json['isValidAccount']}', caseSensitive: false) ?? false : null,
    mysqlConnectionInfo: json['mysqlConnectionInfo'] != null ? MysqlConnectionInfo.fromJson(json['mysqlConnectionInfo'] as Map<String, dynamic>) : null
  );
  
  Map<String, dynamic> toJson() => {
    'syncHistory': syncHistory,
    'syncReadProgress': syncReadProgress,
    'syncGroupProfile': syncGroupProfile,
    'syncQuickSearch': syncQuickSearch,
    'isValidAccount': isValidAccount,
    'mysqlConnectionInfo': mysqlConnectionInfo?.toJson()
  };

  MysqlConfig clone() => MysqlConfig(
    syncHistory: syncHistory,
    syncReadProgress: syncReadProgress,
    syncGroupProfile: syncGroupProfile,
    syncQuickSearch: syncQuickSearch,
    isValidAccount: isValidAccount,
    mysqlConnectionInfo: mysqlConnectionInfo?.clone()
  );


  MysqlConfig copyWith({
    Optional<bool?>? syncHistory,
    Optional<bool?>? syncReadProgress,
    Optional<bool?>? syncGroupProfile,
    Optional<bool?>? syncQuickSearch,
    Optional<bool?>? isValidAccount,
    Optional<MysqlConnectionInfo?>? mysqlConnectionInfo
  }) => MysqlConfig(
    syncHistory: checkOptional(syncHistory, () => this.syncHistory),
    syncReadProgress: checkOptional(syncReadProgress, () => this.syncReadProgress),
    syncGroupProfile: checkOptional(syncGroupProfile, () => this.syncGroupProfile),
    syncQuickSearch: checkOptional(syncQuickSearch, () => this.syncQuickSearch),
    isValidAccount: checkOptional(isValidAccount, () => this.isValidAccount),
    mysqlConnectionInfo: checkOptional(mysqlConnectionInfo, () => this.mysqlConnectionInfo),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is MysqlConfig && syncHistory == other.syncHistory && syncReadProgress == other.syncReadProgress && syncGroupProfile == other.syncGroupProfile && syncQuickSearch == other.syncQuickSearch && isValidAccount == other.isValidAccount && mysqlConnectionInfo == other.mysqlConnectionInfo;

  @override
  int get hashCode => syncHistory.hashCode ^ syncReadProgress.hashCode ^ syncGroupProfile.hashCode ^ syncQuickSearch.hashCode ^ isValidAccount.hashCode ^ mysqlConnectionInfo.hashCode;
}
