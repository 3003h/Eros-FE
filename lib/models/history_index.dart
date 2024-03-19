import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class HistoryIndex {

  const HistoryIndex({
    this.time,
    this.gids,
  });

  final int? time;
  final List<HistoryIndexGid>? gids;

  factory HistoryIndex.fromJson(Map<String,dynamic> json) => HistoryIndex(
    time: json['time'] != null ? int.tryParse('${json['time']}') ?? 0 : null,
    gids: json['gids'] != null ? (json['gids'] as List? ?? []).map((e) => HistoryIndexGid.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'time': time,
    'gids': gids?.map((e) => e.toJson()).toList()
  };

  HistoryIndex clone() => HistoryIndex(
    time: time,
    gids: gids?.map((e) => e.clone()).toList()
  );


  HistoryIndex copyWith({
    Optional<int?>? time,
    Optional<List<HistoryIndexGid>?>? gids
  }) => HistoryIndex(
    time: checkOptional(time, () => this.time),
    gids: checkOptional(gids, () => this.gids),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is HistoryIndex && time == other.time && gids == other.gids;

  @override
  int get hashCode => time.hashCode ^ gids.hashCode;
}
