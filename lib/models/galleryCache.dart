import 'package:json_annotation/json_annotation.dart';

part 'galleryCache.g.dart';

@JsonSerializable()
class GalleryCache {
  GalleryCache();

  String gid;
  int lastIndex;
  double lastOffset;

  factory GalleryCache.fromJson(Map<String, dynamic> json) =>
      _$GalleryCacheFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryCacheToJson(this);
}
