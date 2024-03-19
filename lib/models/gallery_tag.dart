import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    title: json['title'].toString(),
    type: json['type'].toString(),
    tagTranslat: json['tagTranslat'].toString(),
    intro: json['intro']?.toString(),
    vote: json['vote'] != null ? int.tryParse('${json['vote']}') ?? 0 : null,
    color: json['color']?.toString(),
    backgrondColor: json['backgrondColor']?.toString(),
    watch: json['watch'] != null ? bool.tryParse('${json['watch']}', caseSensitive: false) ?? false : null,
    hide: json['hide'] != null ? bool.tryParse('${json['hide']}', caseSensitive: false) ?? false : null
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
    Optional<String?>? intro,
    Optional<int?>? vote,
    Optional<String?>? color,
    Optional<String?>? backgrondColor,
    Optional<bool?>? watch,
    Optional<bool?>? hide
  }) => GalleryTag(
    title: title ?? this.title,
    type: type ?? this.type,
    tagTranslat: tagTranslat ?? this.tagTranslat,
    intro: checkOptional(intro, () => this.intro),
    vote: checkOptional(vote, () => this.vote),
    color: checkOptional(color, () => this.color),
    backgrondColor: checkOptional(backgrondColor, () => this.backgrondColor),
    watch: checkOptional(watch, () => this.watch),
    hide: checkOptional(hide, () => this.hide),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryTag && title == other.title && type == other.type && tagTranslat == other.tagTranslat && intro == other.intro && vote == other.vote && color == other.color && backgrondColor == other.backgrondColor && watch == other.watch && hide == other.hide;

  @override
  int get hashCode => title.hashCode ^ type.hashCode ^ tagTranslat.hashCode ^ intro.hashCode ^ vote.hashCode ^ color.hashCode ^ backgrondColor.hashCode ^ watch.hashCode ^ hide.hashCode;
}
