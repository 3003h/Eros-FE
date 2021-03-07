import 'package:flutter/foundation.dart';

import 'advance_search.dart';
import 'auto_lock.dart';
import 'dns_config.dart';
import 'download_config.dart';
import 'eh_config.dart';
import 'local_fav.dart';
import 'user.dart';

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

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
      ehConfig: EhConfig.fromJson(json['eh_config'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      lastLogin: json['last_login'] as String,
      locale: json['locale'] as String,
      theme: json['theme'] as String,
      searchText: json['search_text'] as List<dynamic>,
      localFav: LocalFav.fromJson(json['local_fav'] as Map<String, dynamic>),
      enableAdvanceSearch: json['enable_advance_search'] as bool,
      advanceSearch: AdvanceSearch.fromJson(
          json['advance_search'] as Map<String, dynamic>),
      dnsConfig: DnsConfig.fromJson(json['dns_config'] as Map<String, dynamic>),
      downloadConfig: DownloadConfig.fromJson(
          json['download_config'] as Map<String, dynamic>),
      autoLock: AutoLock.fromJson(json['auto_lock'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {
        'eh_config': ehConfig.toJson(),
        'user': user.toJson(),
        'last_login': lastLogin,
        'locale': locale,
        'theme': theme,
        'search_text': searchText,
        'local_fav': localFav.toJson(),
        'enable_advance_search': enableAdvanceSearch,
        'advance_search': advanceSearch.toJson(),
        'dns_config': dnsConfig.toJson(),
        'download_config': downloadConfig.toJson(),
        'auto_lock': autoLock.toJson()
      };

  Profile clone() => Profile(
      ehConfig: ehConfig.clone(),
      user: user.clone(),
      lastLogin: lastLogin,
      locale: locale,
      theme: theme,
      searchText: searchText,
      localFav: localFav.clone(),
      enableAdvanceSearch: enableAdvanceSearch,
      advanceSearch: advanceSearch.clone(),
      dnsConfig: dnsConfig.clone(),
      downloadConfig: downloadConfig.clone(),
      autoLock: autoLock.clone());

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
          AutoLock? autoLock}) =>
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
          autoLock == other.autoLock;

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
      autoLock.hashCode;
}
