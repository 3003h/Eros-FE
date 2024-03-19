import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    gid: json['gid']?.toString(),
    lastIndex: json['lastIndex'] != null ? int.tryParse('${json['lastIndex']}') ?? 0 : null,
    lastOffset: json['lastOffset'] != null ? double.tryParse('${json['lastOffset']}') ?? 0.0 : null,
    columnModeVal: json['columnModeVal']?.toString(),
    time: json['time'] != null ? int.tryParse('${json['time']}') ?? 0 : null
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
    Optional<String?>? gid,
    Optional<int?>? lastIndex,
    Optional<double?>? lastOffset,
    Optional<String?>? columnModeVal,
    Optional<int?>? time
  }) => GalleryCache(
    gid: checkOptional(gid, () => this.gid),
    lastIndex: checkOptional(lastIndex, () => this.lastIndex),
    lastOffset: checkOptional(lastOffset, () => this.lastOffset),
    columnModeVal: checkOptional(columnModeVal, () => this.columnModeVal),
    time: checkOptional(time, () => this.time),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryCache && gid == other.gid && lastIndex == other.lastIndex && lastOffset == other.lastOffset && columnModeVal == other.columnModeVal && time == other.time;

  @override
  int get hashCode => gid.hashCode ^ lastIndex.hashCode ^ lastOffset.hashCode ^ columnModeVal.hashCode ^ time.hashCode;
}
