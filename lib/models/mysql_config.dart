import 'package:flutter/foundation.dart';

import 'mysql_connection_info.dart';

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

  factory MysqlConfig.fromJson(Map<String, dynamic> json) => MysqlConfig(
      syncHistory:
          json['syncHistory'] != null ? json['syncHistory'] as bool : null,
      syncReadProgress: json['syncReadProgress'] != null
          ? json['syncReadProgress'] as bool
          : null,
      syncGroupProfile: json['syncGroupProfile'] != null
          ? json['syncGroupProfile'] as bool
          : null,
      syncQuickSearch: json['syncQuickSearch'] != null
          ? json['syncQuickSearch'] as bool
          : null,
      isValidAccount: json['isValidAccount'] != null
          ? json['isValidAccount'] as bool
          : null,
      mysqlConnectionInfo: json['mysqlConnectionInfo'] != null
          ? MysqlConnectionInfo.fromJson(
              json['mysqlConnectionInfo'] as Map<String, dynamic>)
          : null);

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
      mysqlConnectionInfo: mysqlConnectionInfo?.clone());

  MysqlConfig copyWith(
          {bool? syncHistory,
          bool? syncReadProgress,
          bool? syncGroupProfile,
          bool? syncQuickSearch,
          bool? isValidAccount,
          MysqlConnectionInfo? mysqlConnectionInfo}) =>
      MysqlConfig(
        syncHistory: syncHistory ?? this.syncHistory,
        syncReadProgress: syncReadProgress ?? this.syncReadProgress,
        syncGroupProfile: syncGroupProfile ?? this.syncGroupProfile,
        syncQuickSearch: syncQuickSearch ?? this.syncQuickSearch,
        isValidAccount: isValidAccount ?? this.isValidAccount,
        mysqlConnectionInfo: mysqlConnectionInfo ?? this.mysqlConnectionInfo,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MysqlConfig &&
          syncHistory == other.syncHistory &&
          syncReadProgress == other.syncReadProgress &&
          syncGroupProfile == other.syncGroupProfile &&
          syncQuickSearch == other.syncQuickSearch &&
          isValidAccount == other.isValidAccount &&
          mysqlConnectionInfo == other.mysqlConnectionInfo;

  @override
  int get hashCode =>
      syncHistory.hashCode ^
      syncReadProgress.hashCode ^
      syncGroupProfile.hashCode ^
      syncQuickSearch.hashCode ^
      isValidAccount.hashCode ^
      mysqlConnectionInfo.hashCode;
}
