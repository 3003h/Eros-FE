// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ehConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EhConfig _$EhConfigFromJson(Map<String, dynamic> json) {
  return EhConfig()
    ..jpnTitle = json['jpnTitle'] as bool
    ..tagTranslat = json['tagTranslat'] as bool
    ..favoritesOrder = json['favoritesOrder'] as String
    ..siteEx = json['siteEx'] as bool
    ..galleryImgBlur = json['galleryImgBlur'] as bool
    ..favPicker = json['favPicker'] as bool;
}

Map<String, dynamic> _$EhConfigToJson(EhConfig instance) => <String, dynamic>{
      'jpnTitle': instance.jpnTitle,
      'tagTranslat': instance.tagTranslat,
      'favoritesOrder': instance.favoritesOrder,
      'siteEx': instance.siteEx,
      'galleryImgBlur': instance.galleryImgBlur,
      'favPicker': instance.favPicker
    };
