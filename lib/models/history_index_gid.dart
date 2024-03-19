import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class HistoryIndexGid {

  const HistoryIndexGid({
    this.t,
    this.g,
  });

  final int? t;
  final String? g;

  factory HistoryIndexGid.fromJson(Map<String,dynamic> json) => HistoryIndexGid(
    t: json['t'] != null ? int.tryParse('${json['t']}') ?? 0 : null,
    g: json['g']?.toString()
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
    Optional<int?>? t,
    Optional<String?>? g
  }) => HistoryIndexGid(
    t: checkOptional(t, () => this.t),
    g: checkOptional(g, () => this.g),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is HistoryIndexGid && t == other.t && g == other.g;

  @override
  int get hashCode => t.hashCode ^ g.hashCode;
}
