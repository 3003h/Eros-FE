import 'package:json_annotation/json_annotation.dart';

part 'ehConfig.g.dart';

@JsonSerializable()
class EhConfig {
    EhConfig();

    bool jpnTitle;
    bool tagTranslat;
    String favoritesOrder;
    bool siteEx;
    bool galleryImgBlur;
    bool favPicker;
    bool favLongTap;
    String lastFavcat;
    
    factory EhConfig.fromJson(Map<String,dynamic> json) => _$EhConfigFromJson(json);
    Map<String, dynamic> toJson() => _$EhConfigToJson(this);
}
