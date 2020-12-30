import 'package:json_annotation/json_annotation.dart';

import 'galleryComment.dart';
import 'galleryPreview.dart';
import 'galleryTorrent.dart';
import 'simpleTag.dart';
import 'tagGroup.dart';

part 'galleryItem.g.dart';

@JsonSerializable()
class GalleryItem {
  GalleryItem();

  String gid;
  String token;
  String showKey;
  String url;
  String imgUrl;
  String imgUrlL;
  double imgHeight;
  double imgWidth;
  String japaneseTitle;
  String englishTitle;
  String category;
  String uploader;
  String posted;
  String language;
  String filecount;
  double rating;
  String torrentcount;
  List<GalleryTorrent> torrents;
  int filesize;
  double ratingFallBack;
  String numberOfReviews;
  String postTime;
  String favTitle;
  String favcat;
  bool localFav;
  List<SimpleTag> simpleTags;
  List<String> tagsFromApi;
  String translated;
  List<TagGroup> tagGroup;
  List<GalleryComment> galleryComment;
  List<GalleryPreview> galleryPreview;
  String apikey;
  String apiuid;
  bool isRatinged;
  String archiverLink;

  factory GalleryItem.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryItemToJson(this);
}
