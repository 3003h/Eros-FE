import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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

  factory DnsConfig.fromJson(Map<String,dynamic> json) => DnsConfig(
    enableDoH: json['enableDoH'] != null ? bool.tryParse('${json['enableDoH']}', caseSensitive: false) ?? false : null,
    enableCustomHosts: json['enableCustomHosts'] != null ? bool.tryParse('${json['enableCustomHosts']}', caseSensitive: false) ?? false : null,
    enableDomainFronting: json['enableDomainFronting'] != null ? bool.tryParse('${json['enableDomainFronting']}', caseSensitive: false) ?? false : null,
    hosts: json['hosts'] != null ? (json['hosts'] as List? ?? []).map((e) => DnsCache.fromJson(e as Map<String, dynamic>)).toList() : null,
    dohCache: json['dohCache'] != null ? (json['dohCache'] as List? ?? []).map((e) => DnsCache.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
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
    dohCache: dohCache?.map((e) => e.clone()).toList()
  );


  DnsConfig copyWith({
    Optional<bool?>? enableDoH,
    Optional<bool?>? enableCustomHosts,
    Optional<bool?>? enableDomainFronting,
    Optional<List<DnsCache>?>? hosts,
    Optional<List<DnsCache>?>? dohCache
  }) => DnsConfig(
    enableDoH: checkOptional(enableDoH, () => this.enableDoH),
    enableCustomHosts: checkOptional(enableCustomHosts, () => this.enableCustomHosts),
    enableDomainFronting: checkOptional(enableDomainFronting, () => this.enableDomainFronting),
    hosts: checkOptional(hosts, () => this.hosts),
    dohCache: checkOptional(dohCache, () => this.dohCache),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is DnsConfig && enableDoH == other.enableDoH && enableCustomHosts == other.enableCustomHosts && enableDomainFronting == other.enableDomainFronting && hosts == other.hosts && dohCache == other.dohCache;

  @override
  int get hashCode => enableDoH.hashCode ^ enableCustomHosts.hashCode ^ enableDomainFronting.hashCode ^ hosts.hashCode ^ dohCache.hashCode;
}
