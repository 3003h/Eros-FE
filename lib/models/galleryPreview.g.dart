// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryPreview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryPreview _$GalleryPreviewFromJson(Map<String, dynamic> json) {
  return GalleryPreview()
    ..isLarge = json['isLarge'] as bool
    ..isCache = json['isCache'] as bool
    ..ser = json['ser'] as int
    ..href = json['href'] as String
    ..largeImageUrl = json['largeImageUrl'] as String
    ..imgUrl = json['imgUrl'] as String
    ..height = (json['height'] as num)?.toDouble()
    ..width = (json['width'] as num)?.toDouble()
    ..offSet = (json['offSet'] as num)?.toDouble();
}

Map<String, dynamic> _$GalleryPreviewToJson(GalleryPreview instance) =>
    <String, dynamic>{
      'isLarge': instance.isLarge,
      'isCache': instance.isCache,
      'ser': instance.ser,
      'href': instance.href,
      'largeImageUrl': instance.largeImageUrl,
      'imgUrl': instance.imgUrl,
      'height': instance.height,
      'width': instance.width,
      'offSet': instance.offSet,
    };
