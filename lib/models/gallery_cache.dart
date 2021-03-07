import 'package:flutter/foundation.dart';


@immutable
class GalleryCache {
  
  const GalleryCache({
    this.gid,
    this.lastIndex,
    this.lastOffset,
    this.columnModeVal,
  });

  final String? gid;
  final int? lastIndex;
  final double? lastOffset;
  final String? columnModeVal;

  factory GalleryCache.fromJson(Map<String,dynamic> json) => GalleryCache(
    gid: json['gid'] != null ? json['gid'] as String : null,
    lastIndex: json['last_index'] != null ? json['last_index'] as int : null,
    lastOffset: json['last_offset'] != null ? json['last_offset'] as double : null,
    columnModeVal: json['column_mode_val'] != null ? json['column_mode_val'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'gid': gid,
    'last_index': lastIndex,
    'last_offset': lastOffset,
    'column_mode_val': columnModeVal
  };

  GalleryCache clone() => GalleryCache(
    gid: gid,
    lastIndex: lastIndex,
    lastOffset: lastOffset,
    columnModeVal: columnModeVal
  );

    
  GalleryCache copyWith({
    String? gid,
    int? lastIndex,
    double? lastOffset,
    String? columnModeVal
  }) => GalleryCache(
    gid: gid ?? this.gid,
    lastIndex: lastIndex ?? this.lastIndex,
    lastOffset: lastOffset ?? this.lastOffset,
    columnModeVal: columnModeVal ?? this.columnModeVal,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryCache && gid == other.gid && lastIndex == other.lastIndex && lastOffset == other.lastOffset && columnModeVal == other.columnModeVal;

  @override
  int get hashCode => gid.hashCode ^ lastIndex.hashCode ^ lastOffset.hashCode ^ columnModeVal.hashCode;
}
