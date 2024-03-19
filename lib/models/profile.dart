import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    this.layoutConfig,
    this.blockConfig,
    this.mysqlConfig,
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
  final LayoutConfig? layoutConfig;
  final BlockConfig? blockConfig;
  final MysqlConfig? mysqlConfig;

  factory Profile.fromJson(Map<String,dynamic> json) => Profile(
    ehConfig: EhConfig.fromJson(json['ehConfig'] as Map<String, dynamic>),
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    lastLogin: json['lastLogin'].toString(),
    locale: json['locale'].toString(),
    theme: json['theme'].toString(),
    searchText: (json['searchText'] as List? ?? []).map((e) => e as dynamic).toList(),
    localFav: LocalFav.fromJson(json['localFav'] as Map<String, dynamic>),
    enableAdvanceSearch: bool.tryParse('${json['enableAdvanceSearch']}', caseSensitive: false) ?? false,
    advanceSearch: AdvanceSearch.fromJson(json['advanceSearch'] as Map<String, dynamic>),
    dnsConfig: DnsConfig.fromJson(json['dnsConfig'] as Map<String, dynamic>),
    downloadConfig: DownloadConfig.fromJson(json['downloadConfig'] as Map<String, dynamic>),
    autoLock: AutoLock.fromJson(json['autoLock'] as Map<String, dynamic>),
    webdav: json['webdav'] != null ? WebdavProfile.fromJson(json['webdav'] as Map<String, dynamic>) : null,
    favConfig: json['favConfig'] != null ? FavConfig.fromJson(json['favConfig'] as Map<String, dynamic>) : null,
    customTabConfig: json['customTabConfig'] != null ? CustomTabConfig.fromJson(json['customTabConfig'] as Map<String, dynamic>) : null,
    tabConfig: json['tabConfig'] != null ? TabConfig.fromJson(json['tabConfig'] as Map<String, dynamic>) : null,
    layoutConfig: json['layoutConfig'] != null ? LayoutConfig.fromJson(json['layoutConfig'] as Map<String, dynamic>) : null,
    blockConfig: json['blockConfig'] != null ? BlockConfig.fromJson(json['blockConfig'] as Map<String, dynamic>) : null,
    mysqlConfig: json['mysqlConfig'] != null ? MysqlConfig.fromJson(json['mysqlConfig'] as Map<String, dynamic>) : null
  );
  
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
    'tabConfig': tabConfig?.toJson(),
    'layoutConfig': layoutConfig?.toJson(),
    'blockConfig': blockConfig?.toJson(),
    'mysqlConfig': mysqlConfig?.toJson()
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
    tabConfig: tabConfig?.clone(),
    layoutConfig: layoutConfig?.clone(),
    blockConfig: blockConfig?.clone(),
    mysqlConfig: mysqlConfig?.clone()
  );


  Profile copyWith({
    EhConfig? ehConfig,
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
    Optional<WebdavProfile?>? webdav,
    Optional<FavConfig?>? favConfig,
    Optional<CustomTabConfig?>? customTabConfig,
    Optional<TabConfig?>? tabConfig,
    Optional<LayoutConfig?>? layoutConfig,
    Optional<BlockConfig?>? blockConfig,
    Optional<MysqlConfig?>? mysqlConfig
  }) => Profile(
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
    webdav: checkOptional(webdav, () => this.webdav),
    favConfig: checkOptional(favConfig, () => this.favConfig),
    customTabConfig: checkOptional(customTabConfig, () => this.customTabConfig),
    tabConfig: checkOptional(tabConfig, () => this.tabConfig),
    layoutConfig: checkOptional(layoutConfig, () => this.layoutConfig),
    blockConfig: checkOptional(blockConfig, () => this.blockConfig),
    mysqlConfig: checkOptional(mysqlConfig, () => this.mysqlConfig),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Profile && ehConfig == other.ehConfig && user == other.user && lastLogin == other.lastLogin && locale == other.locale && theme == other.theme && searchText == other.searchText && localFav == other.localFav && enableAdvanceSearch == other.enableAdvanceSearch && advanceSearch == other.advanceSearch && dnsConfig == other.dnsConfig && downloadConfig == other.downloadConfig && autoLock == other.autoLock && webdav == other.webdav && favConfig == other.favConfig && customTabConfig == other.customTabConfig && tabConfig == other.tabConfig && layoutConfig == other.layoutConfig && blockConfig == other.blockConfig && mysqlConfig == other.mysqlConfig;

  @override
  int get hashCode => ehConfig.hashCode ^ user.hashCode ^ lastLogin.hashCode ^ locale.hashCode ^ theme.hashCode ^ searchText.hashCode ^ localFav.hashCode ^ enableAdvanceSearch.hashCode ^ advanceSearch.hashCode ^ dnsConfig.hashCode ^ downloadConfig.hashCode ^ autoLock.hashCode ^ webdav.hashCode ^ favConfig.hashCode ^ customTabConfig.hashCode ^ tabConfig.hashCode ^ layoutConfig.hashCode ^ blockConfig.hashCode ^ mysqlConfig.hashCode;
}
