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
    this.watch,
    this.hide,
  });

  final String title;
  final String type;
  final String tagTranslat;
  final String? intro;
  final int? vote;
  final String? color;
  final String? backgrondColor;
  final bool? watch;
  final bool? hide;

  factory GalleryTag.fromJson(Map<String,dynamic> json) => GalleryTag(
    title: json['title'] as String,
    type: json['type'] as String,
    tagTranslat: json['tagTranslat'] as String,
    intro: json['intro'] != null ? json['intro'] as String : null,
    vote: json['vote'] != null ? json['vote'] as int : null,
    color: json['color'] != null ? json['color'] as String : null,
    backgrondColor: json['backgrondColor'] != null ? json['backgrondColor'] as String : null,
    watch: json['watch'] != null ? json['watch'] as bool : null,
    hide: json['hide'] != null ? json['hide'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type,
    'tagTranslat': tagTranslat,
    'intro': intro,
    'vote': vote,
    'color': color,
    'backgrondColor': backgrondColor,
    'watch': watch,
    'hide': hide
  };

  GalleryTag clone() => GalleryTag(
    title: title,
    type: type,
    tagTranslat: tagTranslat,
    intro: intro,
    vote: vote,
    color: color,
    backgrondColor: backgrondColor,
    watch: watch,
    hide: hide
  );

    
  GalleryTag copyWith({
    String? title,
    String? type,
    String? tagTranslat,
    String? intro,
    int? vote,
    String? color,
    String? backgrondColor,
    bool? watch,
    bool? hide
  }) => GalleryTag(
    title: title ?? this.title,
    type: type ?? this.type,
    tagTranslat: tagTranslat ?? this.tagTranslat,
    intro: intro ?? this.intro,
    vote: vote ?? this.vote,
    color: color ?? this.color,
    backgrondColor: backgrondColor ?? this.backgrondColor,
    watch: watch ?? this.watch,
    hide: hide ?? this.hide,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryTag && title == other.title && type == other.type && tagTranslat == other.tagTranslat && intro == other.intro && vote == other.vote && color == other.color && backgrondColor == other.backgrondColor && watch == other.watch && hide == other.hide;

  @override
  int get hashCode => title.hashCode ^ type.hashCode ^ tagTranslat.hashCode ^ intro.hashCode ^ vote.hashCode ^ color.hashCode ^ backgrondColor.hashCode ^ watch.hashCode ^ hide.hashCode;
}
