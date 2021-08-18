import 'package:flutter/foundation.dart';
import 'history_index_gid.dart';

@immutable
class HistoryIndex {
  
  const HistoryIndex({
    this.time,
    this.gids,
  });

  final int? time;
  final List<HistoryIndexGid>? gids;

  factory HistoryIndex.fromJson(Map<String,dynamic> json) => HistoryIndex(
    time: json['time'] != null ? json['time'] as int : null,
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
    int? time,
    List<HistoryIndexGid>? gids
  }) => HistoryIndex(
    time: time ?? this.time,
    gids: gids ?? this.gids,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is HistoryIndex && time == other.time && gids == other.gids;

  @override
  int get hashCode => time.hashCode ^ gids.hashCode;
}
