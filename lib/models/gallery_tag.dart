import 'package:flutter/foundation.dart';


@immutable
class GalleryTag {
  
  const GalleryTag({
    required this.title,
    required this.type,
    required this.tagTranslat,
    this.intro,
    this.vote,
  });

  final String title;
  final String type;
  final String tagTranslat;
  final String? intro;
  final int? vote;

  factory GalleryTag.fromJson(Map<String,dynamic> json) => GalleryTag(
    title: json['title'] as String,
    type: json['type'] as String,
    tagTranslat: json['tagTranslat'] as String,
    intro: json['intro'] != null ? json['intro'] as String : null,
    vote: json['vote'] != null ? json['vote'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type,
    'tagTranslat': tagTranslat,
    'intro': intro,
    'vote': vote
  };

  GalleryTag clone() => GalleryTag(
    title: title,
    type: type,
    tagTranslat: tagTranslat,
    intro: intro,
    vote: vote
  );

    
  GalleryTag copyWith({
    String? title,
    String? type,
    String? tagTranslat,
    String? intro,
    int? vote
  }) => GalleryTag(
    title: title ?? this.title,
    type: type ?? this.type,
    tagTranslat: tagTranslat ?? this.tagTranslat,
    intro: intro ?? this.intro,
    vote: vote ?? this.vote,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryTag && title == other.title && type == other.type && tagTranslat == other.tagTranslat && intro == other.intro && vote == other.vote;

  @override
  int get hashCode => title.hashCode ^ type.hashCode ^ tagTranslat.hashCode ^ intro.hashCode ^ vote.hashCode;
}
