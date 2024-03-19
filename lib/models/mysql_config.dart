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
    syncHistory: json['syncHistory'] != null ? json['syncHistory'] as bool : null,
    syncReadProgress: json['syncReadProgress'] != null ? json['syncReadProgress'] as bool : null,
    syncGroupProfile: json['syncGroupProfile'] != null ? json['syncGroupProfile'] as bool : null,
    syncQuickSearch: json['syncQuickSearch'] != null ? json['syncQuickSearch'] as bool : null,
    isValidAccount: json['isValidAccount'] != null ? json['isValidAccount'] as bool : null,
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
