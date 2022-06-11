import 'package:flutter/foundation.dart';

import 'mvp_image.dart';

@immutable
class Mpv {
  const Mpv({
    this.mpvkey,
    this.gid,
    this.imagelist,
  });

  final String? mpvkey;
  final int? gid;
  final List<MvpImage>? imagelist;

  factory Mpv.fromJson(Map<String, dynamic> json) => Mpv(
      mpvkey: json['mpvkey'] != null ? json['mpvkey'] as String : null,
      gid: json['gid'] != null ? json['gid'] as int : null,
      imagelist: json['imagelist'] != null
          ? (json['imagelist'] as List? ?? [])
              .map((e) => MvpImage.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'mpvkey': mpvkey,
        'gid': gid,
        'imagelist': imagelist?.map((e) => e.toJson()).toList()
      };

  Mpv clone() => Mpv(
      mpvkey: mpvkey,
      gid: gid,
      imagelist: imagelist?.map((e) => e.clone()).toList());

  Mpv copyWith({String? mpvkey, int? gid, List<MvpImage>? imagelist}) => Mpv(
        mpvkey: mpvkey ?? this.mpvkey,
        gid: gid ?? this.gid,
        imagelist: imagelist ?? this.imagelist,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mpv &&
          mpvkey == other.mpvkey &&
          gid == other.gid &&
          imagelist == other.imagelist;

  @override
  int get hashCode => mpvkey.hashCode ^ gid.hashCode ^ imagelist.hashCode;
}
