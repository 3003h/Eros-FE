// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ehConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EhConfig _$EhConfigFromJson(Map<String, dynamic> json) {
  return EhConfig()
    ..jpnTitle = json['jpnTitle'] as bool
    ..tagTranslat = json['tagTranslat'] as bool
    ..tagTranslatVer = json['tagTranslatVer'] as String
    ..favoritesOrder = json['favoritesOrder'] as String
    ..siteEx = json['siteEx'] as bool
    ..galleryImgBlur = json['galleryImgBlur'] as bool
    ..favPicker = json['favPicker'] as bool
    ..favLongTap = json['favLongTap'] as bool
    ..lastFavcat = json['lastFavcat'] as String
    ..listMode = json['listMode'] as String
    ..safeMode = json['safeMode'] as bool;
}

Map<String, dynamic> _$EhConfigToJson(EhConfig instance) => <String, dynamic>{
      'jpnTitle': instance.jpnTitle,
      'tagTranslat': instance.tagTranslat,
      'tagTranslatVer': instance.tagTranslatVer,
      'favoritesOrder': instance.favoritesOrder,
      'siteEx': instance.siteEx,
      'galleryImgBlur': instance.galleryImgBlur,
      'favPicker': instance.favPicker,
      'favLongTap': instance.favLongTap,
      'lastFavcat': instance.lastFavcat,
      'listMode': instance.listMode,
      'safeMode': instance.safeMode
    };
