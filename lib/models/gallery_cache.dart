import 'package:flutter/foundation.dart';


@immutable
class GalleryCache {
  
  const GalleryCache({
    this.gid,
    this.lastIndex,
    this.lastOffset,
    this.columnModeVal,
    this.time,
  });

  final String? gid;
  final int? lastIndex;
  final double? lastOffset;
  final String? columnModeVal;
  final int? time;

  factory GalleryCache.fromJson(Map<String,dynamic> json) => GalleryCache(
    gid: json['gid'] != null ? json['gid'] as String : null,
    lastIndex: json['lastIndex'] != null ? json['lastIndex'] as int : null,
    lastOffset: json['lastOffset'] != null ? json['lastOffset'] as double : null,
    columnModeVal: json['columnModeVal'] != null ? json['columnModeVal'] as String : null,
    time: json['time'] != null ? json['time'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'gid': gid,
    'lastIndex': lastIndex,
    'lastOffset': lastOffset,
    'columnModeVal': columnModeVal,
    'time': time
  };

  GalleryCache clone() => GalleryCache(
    gid: gid,
    lastIndex: lastIndex,
    lastOffset: lastOffset,
    columnModeVal: columnModeVal,
    time: time
  );

    
  GalleryCache copyWith({
    String? gid,
    int? lastIndex,
    double? lastOffset,
    String? columnModeVal,
    int? time
  }) => GalleryCache(
    gid: gid ?? this.gid,
    lastIndex: lastIndex ?? this.lastIndex,
    lastOffset: lastOffset ?? this.lastOffset,
    columnModeVal: columnModeVal ?? this.columnModeVal,
    time: time ?? this.time,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryCache && gid == other.gid && lastIndex == other.lastIndex && lastOffset == other.lastOffset && columnModeVal == other.columnModeVal && time == other.time;

  @override
  int get hashCode => gid.hashCode ^ lastIndex.hashCode ^ lastOffset.hashCode ^ columnModeVal.hashCode ^ time.hashCode;
}
