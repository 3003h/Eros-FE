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

  factory GalleryCache.fromJson(Map<String, dynamic> json) => GalleryCache(
      gid: json['gid'] != null ? json['gid'] as String : null,
      lastIndex: json['lastIndex'] != null ? json['lastIndex'] as int : null,
      lastOffset:
          json['lastOffset'] != null ? json['lastOffset'] as double : null,
      columnModeVal: json['columnModeVal'] != null
          ? json['columnModeVal'] as String
          : null);

  Map<String, dynamic> toJson() => {
        'gid': gid,
        'lastIndex': lastIndex,
        'lastOffset': lastOffset,
        'columnModeVal': columnModeVal
      };

  GalleryCache clone() => GalleryCache(
      gid: gid,
      lastIndex: lastIndex,
      lastOffset: lastOffset,
      columnModeVal: columnModeVal);

  GalleryCache copyWith(
          {String? gid,
          int? lastIndex,
          double? lastOffset,
          String? columnModeVal}) =>
      GalleryCache(
        gid: gid ?? this.gid,
        lastIndex: lastIndex ?? this.lastIndex,
        lastOffset: lastOffset ?? this.lastOffset,
        columnModeVal: columnModeVal ?? this.columnModeVal,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryCache &&
          gid == other.gid &&
          lastIndex == other.lastIndex &&
          lastOffset == other.lastOffset &&
          columnModeVal == other.columnModeVal;

  @override
  int get hashCode =>
      gid.hashCode ^
      lastIndex.hashCode ^
      lastOffset.hashCode ^
      columnModeVal.hashCode;
}
