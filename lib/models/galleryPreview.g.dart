// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryPreview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryPreview _$GalleryPreviewFromJson(Map<String, dynamic> json) {
  return GalleryPreview()
    ..isLarge = json['isLarge'] as bool
    ..ser = json['ser'] as num
    ..href = json['href'] as String
    ..largeImageUrl = json['largeImageUrl'] as String
    ..imgUrl = json['imgUrl'] as String
    ..height = json['height'] as num
    ..width = json['width'] as num
    ..offSet = json['offSet'] as num;
}

Map<String, dynamic> _$GalleryPreviewToJson(GalleryPreview instance) =>
    <String, dynamic>{
      'isLarge': instance.isLarge,
      'ser': instance.ser,
      'href': instance.href,
      'largeImageUrl': instance.largeImageUrl,
      'imgUrl': instance.imgUrl,
      'height': instance.height,
      'width': instance.width,
      'offSet': instance.offSet
    };
