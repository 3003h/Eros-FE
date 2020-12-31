import 'package:json_annotation/json_annotation.dart';

part 'galleryComment.g.dart';

@JsonSerializable()
class GalleryComment {
      GalleryComment();

  String name;
  String time;
  String context;
  String score;

  factory GalleryComment.fromJson(Map<String,dynamic> json) => _$GalleryCommentFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryCommentToJson(this);
}
