import 'package:flutter/foundation.dart';


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
    host: json['host'] != null ? json['host'] as String : null,
    lastResolve: json['lastResolve'] != null ? json['lastResolve'] as int : null,
    ttl: json['ttl'] != null ? json['ttl'] as int : null,
    addrs: json['addrs'] != null ? (json['addrs'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    addr: json['addr'] != null ? json['addr'] as String : null
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
    String? host,
    int? lastResolve,
    int? ttl,
    List<dynamic>? addrs,
    String? addr
  }) => DnsCache(
    host: host ?? this.host,
    lastResolve: lastResolve ?? this.lastResolve,
    ttl: ttl ?? this.ttl,
    addrs: addrs ?? this.addrs,
    addr: addr ?? this.addr,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is DnsCache && host == other.host && lastResolve == other.lastResolve && ttl == other.ttl && addrs == other.addrs && addr == other.addr;

  @override
  int get hashCode => host.hashCode ^ lastResolve.hashCode ^ ttl.hashCode ^ addrs.hashCode ^ addr.hashCode;
}
