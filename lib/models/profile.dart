import 'package:flutter/foundation.dart';

import 'advance_search.dart';
import 'auto_lock.dart';
import 'custom_tab_config.dart';
import 'dns_config.dart';
import 'download_config.dart';
import 'eh_config.dart';
import 'fav_config.dart';
import 'local_fav.dart';
import 'tab_config.dart';
import 'user.dart';
import 'webdav_profile.dart';

@immutable
class Profile {
  const Profile({
    required this.ehConfig,
    required this.user,
    required this.lastLogin,
    required this.locale,
    required this.theme,
    required this.searchText,
    required this.localFav,
    required this.enableAdvanceSearch,
    required this.advanceSearch,
    required this.dnsConfig,
    required this.downloadConfig,
    required this.autoLock,
    this.webdav,
    this.favConfig,
    this.customTabConfig,
    this.tabConfig,
  });

  final EhConfig ehConfig;
  final User user;
  final String lastLogin;
  final String locale;
  final String theme;
  final List<dynamic> searchText;
  final LocalFav localFav;
  final bool enableAdvanceSearch;
  final AdvanceSearch advanceSearch;
  final DnsConfig dnsConfig;
  final DownloadConfig downloadConfig;
  final AutoLock autoLock;
  final WebdavProfile? webdav;
  final FavConfig? favConfig;
  final CustomTabConfig? customTabConfig;
  final TabConfig? tabConfig;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
      ehConfig: EhConfig.fromJson(json['ehConfig'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      lastLogin: json['lastLogin'] as String,
      locale: json['locale'] as String,
      theme: json['theme'] as String,
      searchText:
          (json['searchText'] as List? ?? []).map((e) => e as dynamic).toList(),
      localFav: LocalFav.fromJson(json['localFav'] as Map<String, dynamic>),
      enableAdvanceSearch: json['enableAdvanceSearch'] as bool,
      advanceSearch:
          AdvanceSearch.fromJson(json['advanceSearch'] as Map<String, dynamic>),
      dnsConfig: DnsConfig.fromJson(json['dnsConfig'] as Map<String, dynamic>),
      downloadConfig: DownloadConfig.fromJson(
          json['downloadConfig'] as Map<String, dynamic>),
      autoLock: AutoLock.fromJson(json['autoLock'] as Map<String, dynamic>),
      webdav: json['webdav'] != null
          ? WebdavProfile.fromJson(json['webdav'] as Map<String, dynamic>)
          : null,
      favConfig: json['favConfig'] != null
          ? FavConfig.fromJson(json['favConfig'] as Map<String, dynamic>)
          : null,
      customTabConfig: json['customTabConfig'] != null
          ? CustomTabConfig.fromJson(
              json['customTabConfig'] as Map<String, dynamic>)
          : null,
      tabConfig: json['tabConfig'] != null
          ? TabConfig.fromJson(json['tabConfig'] as Map<String, dynamic>)
          : null);

  Map<String, dynamic> toJson() => {
        'ehConfig': ehConfig.toJson(),
        'user': user.toJson(),
        'lastLogin': lastLogin,
        'locale': locale,
        'theme': theme,
        'searchText': searchText.map((e) => e.toString()).toList(),
        'localFav': localFav.toJson(),
        'enableAdvanceSearch': enableAdvanceSearch,
        'advanceSearch': advanceSearch.toJson(),
        'dnsConfig': dnsConfig.toJson(),
        'downloadConfig': downloadConfig.toJson(),
        'autoLock': autoLock.toJson(),
        'webdav': webdav?.toJson(),
        'favConfig': favConfig?.toJson(),
        'customTabConfig': customTabConfig?.toJson(),
        'tabConfig': tabConfig?.toJson()
      };

  Profile clone() => Profile(
      ehConfig: ehConfig.clone(),
      user: user.clone(),
      lastLogin: lastLogin,
      locale: locale,
      theme: theme,
      searchText: searchText.toList(),
      localFav: localFav.clone(),
      enableAdvanceSearch: enableAdvanceSearch,
      advanceSearch: advanceSearch.clone(),
      dnsConfig: dnsConfig.clone(),
      downloadConfig: downloadConfig.clone(),
      autoLock: autoLock.clone(),
      webdav: webdav?.clone(),
      favConfig: favConfig?.clone(),
      customTabConfig: customTabConfig?.clone(),
      tabConfig: tabConfig?.clone());

  Profile copyWith(
          {EhConfig? ehConfig,
          User? user,
          String? lastLogin,
          String? locale,
          String? theme,
          List<dynamic>? searchText,
          LocalFav? localFav,
          bool? enableAdvanceSearch,
          AdvanceSearch? advanceSearch,
          DnsConfig? dnsConfig,
          DownloadConfig? downloadConfig,
          AutoLock? autoLock,
          WebdavProfile? webdav,
          FavConfig? favConfig,
          CustomTabConfig? customTabConfig,
          TabConfig? tabConfig}) =>
      Profile(
        ehConfig: ehConfig ?? this.ehConfig,
        user: user ?? this.user,
        lastLogin: lastLogin ?? this.lastLogin,
        locale: locale ?? this.locale,
        theme: theme ?? this.theme,
        searchText: searchText ?? this.searchText,
        localFav: localFav ?? this.localFav,
        enableAdvanceSearch: enableAdvanceSearch ?? this.enableAdvanceSearch,
        advanceSearch: advanceSearch ?? this.advanceSearch,
        dnsConfig: dnsConfig ?? this.dnsConfig,
        downloadConfig: downloadConfig ?? this.downloadConfig,
        autoLock: autoLock ?? this.autoLock,
        webdav: webdav ?? this.webdav,
        favConfig: favConfig ?? this.favConfig,
        customTabConfig: customTabConfig ?? this.customTabConfig,
        tabConfig: tabConfig ?? this.tabConfig,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          ehConfig == other.ehConfig &&
          user == other.user &&
          lastLogin == other.lastLogin &&
          locale == other.locale &&
          theme == other.theme &&
          searchText == other.searchText &&
          localFav == other.localFav &&
          enableAdvanceSearch == other.enableAdvanceSearch &&
          advanceSearch == other.advanceSearch &&
          dnsConfig == other.dnsConfig &&
          downloadConfig == other.downloadConfig &&
          autoLock == other.autoLock &&
          webdav == other.webdav &&
          favConfig == other.favConfig &&
          customTabConfig == other.customTabConfig &&
          tabConfig == other.tabConfig;

  @override
  int get hashCode =>
      ehConfig.hashCode ^
      user.hashCode ^
      lastLogin.hashCode ^
      locale.hashCode ^
      theme.hashCode ^
      searchText.hashCode ^
      localFav.hashCode ^
      enableAdvanceSearch.hashCode ^
      advanceSearch.hashCode ^
      dnsConfig.hashCode ^
      downloadConfig.hashCode ^
      autoLock.hashCode ^
      webdav.hashCode ^
      favConfig.hashCode ^
      customTabConfig.hashCode ^
      tabConfig.hashCode;
}
