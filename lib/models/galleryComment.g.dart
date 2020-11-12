// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryComment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryComment _$GalleryCommentFromJson(Map<String, dynamic> json) {
  return GalleryComment()
    ..name = json['name'] as String
    ..time = json['time'] as String
    ..context = json['context'] as String
    ..score = json['score'] as String;
}

Map<String, dynamic> _$GalleryCommentToJson(GalleryComment instance) =>
    <String, dynamic>{
      'name': instance.name,
      'time': instance.time,
      'context': instance.context,
      'score': instance.score,
    };
