import 'package:flutter/foundation.dart';

import 'dns_cache.dart';

@immutable
class DnsConfig {
  const DnsConfig({
    this.enableDoH,
    this.enableCustomHosts,
    this.enableDomainFronting,
    this.hosts,
    this.dohCache,
  });

  final bool? enableDoH;
  final bool? enableCustomHosts;
  final bool? enableDomainFronting;
  final List<DnsCache>? hosts;
  final List<DnsCache>? dohCache;

  factory DnsConfig.fromJson(Map<String, dynamic> json) => DnsConfig(
      enableDoH: json['enableDoH'] != null ? json['enableDoH'] as bool : null,
      enableCustomHosts: json['enableCustomHosts'] != null
          ? json['enableCustomHosts'] as bool
          : null,
      enableDomainFronting: json['enableDomainFronting'] != null
          ? json['enableDomainFronting'] as bool
          : null,
      hosts: json['hosts'] != null
          ? (json['hosts'] as List? ?? [])
              .map((e) => DnsCache.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      dohCache: json['dohCache'] != null
          ? (json['dohCache'] as List? ?? [])
              .map((e) => DnsCache.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'enableDoH': enableDoH,
        'enableCustomHosts': enableCustomHosts,
        'enableDomainFronting': enableDomainFronting,
        'hosts': hosts?.map((e) => e.toJson()).toList(),
        'dohCache': dohCache?.map((e) => e.toJson()).toList()
      };

  DnsConfig clone() => DnsConfig(
      enableDoH: enableDoH,
      enableCustomHosts: enableCustomHosts,
      enableDomainFronting: enableDomainFronting,
      hosts: hosts?.map((e) => e.clone()).toList(),
      dohCache: dohCache?.map((e) => e.clone()).toList());

  DnsConfig copyWith(
          {bool? enableDoH,
          bool? enableCustomHosts,
          bool? enableDomainFronting,
          List<DnsCache>? hosts,
          List<DnsCache>? dohCache}) =>
      DnsConfig(
        enableDoH: enableDoH ?? this.enableDoH,
        enableCustomHosts: enableCustomHosts ?? this.enableCustomHosts,
        enableDomainFronting: enableDomainFronting ?? this.enableDomainFronting,
        hosts: hosts ?? this.hosts,
        dohCache: dohCache ?? this.dohCache,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DnsConfig &&
          enableDoH == other.enableDoH &&
          enableCustomHosts == other.enableCustomHosts &&
          enableDomainFronting == other.enableDomainFronting &&
          hosts == other.hosts &&
          dohCache == other.dohCache;

  @override
  int get hashCode =>
      enableDoH.hashCode ^
      enableCustomHosts.hashCode ^
      enableDomainFronting.hashCode ^
      hosts.hashCode ^
      dohCache.hashCode;
}
