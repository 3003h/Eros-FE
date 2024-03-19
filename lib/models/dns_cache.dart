import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class DnsCache {

  const DnsCache({
    this.host,
    this.lastResolve,
    this.ttl,
    this.addrs,
    this.addr,
  });

  final String? host;
  final int? lastResolve;
  final int? ttl;
  final List<dynamic>? addrs;
  final String? addr;

  factory DnsCache.fromJson(Map<String,dynamic> json) => DnsCache(
    host: json['host']?.toString(),
    lastResolve: json['lastResolve'] != null ? int.tryParse('${json['lastResolve']}') ?? 0 : null,
    ttl: json['ttl'] != null ? int.tryParse('${json['ttl']}') ?? 0 : null,
    addrs: json['addrs'] != null ? (json['addrs'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    addr: json['addr']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'host': host,
    'lastResolve': lastResolve,
    'ttl': ttl,
    'addrs': addrs?.map((e) => e.toString()).toList(),
    'addr': addr
  };

  DnsCache clone() => DnsCache(
    host: host,
    lastResolve: lastResolve,
    ttl: ttl,
    addrs: addrs?.toList(),
    addr: addr
  );


  DnsCache copyWith({
    Optional<String?>? host,
    Optional<int?>? lastResolve,
    Optional<int?>? ttl,
    Optional<List<dynamic>?>? addrs,
    Optional<String?>? addr
  }) => DnsCache(
    host: checkOptional(host, () => this.host),
    lastResolve: checkOptional(lastResolve, () => this.lastResolve),
    ttl: checkOptional(ttl, () => this.ttl),
    addrs: checkOptional(addrs, () => this.addrs),
    addr: checkOptional(addr, () => this.addr),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is DnsCache && host == other.host && lastResolve == other.lastResolve && ttl == other.ttl && addrs == other.addrs && addr == other.addr;

  @override
  int get hashCode => host.hashCode ^ lastResolve.hashCode ^ ttl.hashCode ^ addrs.hashCode ^ addr.hashCode;
}
