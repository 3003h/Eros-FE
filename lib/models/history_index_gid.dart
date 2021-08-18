import 'package:flutter/foundation.dart';


@immutable
class HistoryIndexGid {
  
  const HistoryIndexGid({
    this.t,
    this.g,
  });

  final int? t;
  final String? g;

  factory HistoryIndexGid.fromJson(Map<String,dynamic> json) => HistoryIndexGid(
    t: json['t'] != null ? json['t'] as int : null,
    g: json['g'] != null ? json['g'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    't': t,
    'g': g
  };

  HistoryIndexGid clone() => HistoryIndexGid(
    t: t,
    g: g
  );

    
  HistoryIndexGid copyWith({
    int? t,
    String? g
  }) => HistoryIndexGid(
    t: t ?? this.t,
    g: g ?? this.g,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is HistoryIndexGid && t == other.t && g == other.g;

  @override
  int get hashCode => t.hashCode ^ g.hashCode;
}
