import 'package:json_annotation/json_annotation.dart';

part 'galleryPreview.g.dart';

@JsonSerializable()
class GalleryPreview {
    GalleryPreview();

    bool isLarge;
    num ser;
    String href;
    String largeImageUrl;
    String imgUrl;
    num height;
    num width;
    num offSet;
    
    factory GalleryPreview.fromJson(Map<String,dynamic> json) => _$GalleryPreviewFromJson(json);
    Map<String, dynamic> toJson() => _$GalleryPreviewToJson(this);
}
