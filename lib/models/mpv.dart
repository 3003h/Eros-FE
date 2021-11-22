import 'package:flutter/foundation.dart';
import 'mvp_image.dart';

@immutable
class Mpv {
  
  const Mpv({
    this.mpvkey,
    this.imagelist,
  });

  final String? mpvkey;
  final List<MvpImage>? imagelist;

  factory Mpv.fromJson(Map<String,dynamic> json) => Mpv(
    mpvkey: json['mpvkey'] != null ? json['mpvkey'] as String : null,
    imagelist: json['imagelist'] != null ? (json['imagelist'] as List? ?? []).map((e) => MvpImage.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'mpvkey': mpvkey,
    'imagelist': imagelist?.map((e) => e.toJson()).toList()
  };

  Mpv clone() => Mpv(
    mpvkey: mpvkey,
    imagelist: imagelist?.map((e) => e.clone()).toList()
  );

    
  Mpv copyWith({
    String? mpvkey,
    List<MvpImage>? imagelist
  }) => Mpv(
    mpvkey: mpvkey ?? this.mpvkey,
    imagelist: imagelist ?? this.imagelist,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is Mpv && mpvkey == other.mpvkey && imagelist == other.imagelist;

  @override
  int get hashCode => mpvkey.hashCode ^ imagelist.hashCode;
}
