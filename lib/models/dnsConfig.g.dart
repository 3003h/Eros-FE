// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dnsConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DnsConfig _$DnsConfigFromJson(Map<String, dynamic> json) {
  return DnsConfig()
    ..doh = json['doh'] as bool
    ..customHosts = json['customHosts'] as bool
    ..hosts = (json['hosts'] as List)
        ?.map((e) =>
            e == null ? null : DnsCache.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..cache = (json['cache'] as List)
        ?.map((e) =>
            e == null ? null : DnsCache.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$DnsConfigToJson(DnsConfig instance) => <String, dynamic>{
      'doh': instance.doh,
      'customHosts': instance.customHosts,
      'hosts': instance.hosts,
      'cache': instance.cache,
    };
