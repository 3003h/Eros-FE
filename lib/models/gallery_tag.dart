import 'package:flutter/foundation.dart';


@immutable
class GalleryTag {
  
  const GalleryTag({
    required this.title,
    required this.type,
    required this.tagTranslat,
    this.intro,
    this.vote,
    this.color,
    this.backgrondColor,
  });

  final String title;
  final String type;
  final String tagTranslat;
  final String? intro;
  final int? vote;
  final String? color;
  final String? backgrondColor;

  factory GalleryTag.fromJson(Map<String,dynamic> json) => GalleryTag(
    title: json['title'] as String,
    type: json['type'] as String,
    tagTranslat: json['tagTranslat'] as String,
    intro: json['intro'] != null ? json['intro'] as String : null,
    vote: json['vote'] != null ? json['vote'] as int : null,
    color: json['color'] != null ? json['color'] as String : null,
    backgrondColor: json['backgrondColor'] != null ? json['backgrondColor'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type,
    'tagTranslat': tagTranslat,
    'intro': intro,
    'vote': vote,
    'color': color,
    'backgrondColor': backgrondColor
  };

  GalleryTag clone() => GalleryTag(
    title: title,
    type: type,
    tagTranslat: tagTranslat,
    intro: intro,
    vote: vote,
    color: color,
    backgrondColor: backgrondColor
  );

    
  GalleryTag copyWith({
    String? title,
    String? type,
    String? tagTranslat,
    String? intro,
    int? vote,
    String? color,
    String? backgrondColor
  }) => GalleryTag(
    title: title ?? this.title,
    type: type ?? this.type,
    tagTranslat: tagTranslat ?? this.tagTranslat,
    intro: intro ?? this.intro,
    vote: vote ?? this.vote,
    color: color ?? this.color,
    backgrondColor: backgrondColor ?? this.backgrondColor,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryTag && title == other.title && type == other.type && tagTranslat == other.tagTranslat && intro == other.intro && vote == other.vote && color == other.color && backgrondColor == other.backgrondColor;

  @override
  int get hashCode => title.hashCode ^ type.hashCode ^ tagTranslat.hashCode ^ intro.hashCode ^ vote.hashCode ^ color.hashCode ^ backgrondColor.hashCode;
}
