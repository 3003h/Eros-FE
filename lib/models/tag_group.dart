import 'package:flutter/foundation.dart';

import 'gallery_tag.dart';

@immutable
class TagGroup {
  const TagGroup({
    this.tagType,
    required this.galleryTags,
  });

  final String? tagType;
  final List<GalleryTag> galleryTags;

  factory TagGroup.fromJson(Map<String, dynamic> json) => TagGroup(
      tagType: json['tagType'] != null ? json['tagType'] as String : null,
      galleryTags: (json['galleryTags'] as List? ?? [])
          .map((e) => GalleryTag.fromJson(e as Map<String, dynamic>))
          .toList());

  Map<String, dynamic> toJson() => {
        'tagType': tagType,
        'galleryTags': galleryTags.map((e) => e.toJson()).toList()
      };

  TagGroup clone() => TagGroup(
      tagType: tagType,
      galleryTags: galleryTags.map((e) => e.clone()).toList());

  TagGroup copyWith({String? tagType, List<GalleryTag>? galleryTags}) =>
      TagGroup(
        tagType: tagType ?? this.tagType,
        galleryTags: galleryTags ?? this.galleryTags,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagGroup &&
          tagType == other.tagType &&
          galleryTags == other.galleryTags;

  @override
  int get hashCode => tagType.hashCode ^ galleryTags.hashCode;
}
