import 'package:json_annotation/json_annotation.dart';

import "galleryComment.dart";
import "galleryPreview.dart";
import "tagGroup.dart";

part 'galleryItem.g.dart';

@JsonSerializable()
class GalleryItem {
  GalleryItem();

  String gid;
  String token;
  String url;
  String imgUrl;
  String imgUrlL;
  String japaneseTitle;
  String englishTitle;
  String category;
  String uploader;
  String posted;
  String language;
  String filecount;
  num rating;
  num ratingFallBack;
  String numberOfReviews;
  String postTime;
  List simpleTags;
  List simpleTagsTranslat;
  List<TagGroup> tagGroup;
  List<GalleryComment> galleryComment;
  List<GalleryPreview> galleryPreview;

  factory GalleryItem.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryItemToJson(this);
}
