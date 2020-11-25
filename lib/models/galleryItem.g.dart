// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'galleryItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryItem _$GalleryItemFromJson(Map<String, dynamic> json) {
  return GalleryItem()
    ..gid = json['gid'] as String
    ..token = json['token'] as String
    ..showKey = json['showKey'] as String
    ..url = json['url'] as String
    ..imgUrl = json['imgUrl'] as String
    ..imgUrlL = json['imgUrlL'] as String
    ..imgHeight = (json['imgHeight'] as num)?.toDouble()
    ..imgWidth = (json['imgWidth'] as num)?.toDouble()
    ..japaneseTitle = json['japaneseTitle'] as String
    ..englishTitle = json['englishTitle'] as String
    ..category = json['category'] as String
    ..uploader = json['uploader'] as String
    ..posted = json['posted'] as String
    ..language = json['language'] as String
    ..filecount = json['filecount'] as String
    ..rating = (json['rating'] as num)?.toDouble()
    ..ratingFallBack = (json['ratingFallBack'] as num)?.toDouble()
    ..numberOfReviews = json['numberOfReviews'] as String
    ..postTime = json['postTime'] as String
    ..favTitle = json['favTitle'] as String
    ..favcat = json['favcat'] as String
    ..localFav = json['localFav'] as bool
    ..simpleTags =
        (json['simpleTags'] as List)?.map((e) => e as String)?.toList()
    ..simpleTagsTranslat =
        (json['simpleTagsTranslat'] as List)?.map((e) => e as String)?.toList()
    ..tagsFromApi =
        (json['tagsFromApi'] as List)?.map((e) => e as String)?.toList()
    ..translated = json['translated'] as String
    ..tagGroup = (json['tagGroup'] as List)
        ?.map((e) =>
            e == null ? null : TagGroup.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..galleryComment = (json['galleryComment'] as List)
        ?.map((e) => e == null
            ? null
            : GalleryComment.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..galleryPreview = (json['galleryPreview'] as List)
        ?.map((e) => e == null
            ? null
            : GalleryPreview.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$GalleryItemToJson(GalleryItem instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'token': instance.token,
      'showKey': instance.showKey,
      'url': instance.url,
      'imgUrl': instance.imgUrl,
      'imgUrlL': instance.imgUrlL,
      'imgHeight': instance.imgHeight,
      'imgWidth': instance.imgWidth,
      'japaneseTitle': instance.japaneseTitle,
      'englishTitle': instance.englishTitle,
      'category': instance.category,
      'uploader': instance.uploader,
      'posted': instance.posted,
      'language': instance.language,
      'filecount': instance.filecount,
      'rating': instance.rating,
      'ratingFallBack': instance.ratingFallBack,
      'numberOfReviews': instance.numberOfReviews,
      'postTime': instance.postTime,
      'favTitle': instance.favTitle,
      'favcat': instance.favcat,
      'localFav': instance.localFav,
      'simpleTags': instance.simpleTags,
      'simpleTagsTranslat': instance.simpleTagsTranslat,
      'tagsFromApi': instance.tagsFromApi,
      'translated': instance.translated,
      'tagGroup': instance.tagGroup,
      'galleryComment': instance.galleryComment,
      'galleryPreview': instance.galleryPreview,
    };
