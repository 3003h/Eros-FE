import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class EhUsertag {

  const EhUsertag({
    required this.title,
    this.tagid,
    this.translate,
    this.watch,
    this.hide,
    this.defaultColor,
    this.colorCode,
    this.borderColor,
    this.textColor,
    this.tagWeight,
  });

  final String title;
  final String? tagid;
  final String? translate;
  final bool? watch;
  final bool? hide;
  final bool? defaultColor;
  final String? colorCode;
  final String? borderColor;
  final String? textColor;
  final String? tagWeight;

  factory EhUsertag.fromJson(Map<String,dynamic> json) => EhUsertag(
    title: json['title'].toString(),
    tagid: json['tagid']?.toString(),
    translate: json['translate']?.toString(),
    watch: json['watch'] != null ? bool.tryParse('${json['watch']}', caseSensitive: false) ?? false : null,
    hide: json['hide'] != null ? bool.tryParse('${json['hide']}', caseSensitive: false) ?? false : null,
    defaultColor: json['defaultColor'] != null ? bool.tryParse('${json['defaultColor']}', caseSensitive: false) ?? false : null,
    colorCode: json['colorCode']?.toString(),
    borderColor: json['borderColor']?.toString(),
    textColor: json['textColor']?.toString(),
    tagWeight: json['tagWeight']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'tagid': tagid,
    'translate': translate,
    'watch': watch,
    'hide': hide,
    'defaultColor': defaultColor,
    'colorCode': colorCode,
    'borderColor': borderColor,
    'textColor': textColor,
    'tagWeight': tagWeight
  };

  EhUsertag clone() => EhUsertag(
    title: title,
    tagid: tagid,
    translate: translate,
    watch: watch,
    hide: hide,
    defaultColor: defaultColor,
    colorCode: colorCode,
    borderColor: borderColor,
    textColor: textColor,
    tagWeight: tagWeight
  );


  EhUsertag copyWith({
    String? title,
    Optional<String?>? tagid,
    Optional<String?>? translate,
    Optional<bool?>? watch,
    Optional<bool?>? hide,
    Optional<bool?>? defaultColor,
    Optional<String?>? colorCode,
    Optional<String?>? borderColor,
    Optional<String?>? textColor,
    Optional<String?>? tagWeight
  }) => EhUsertag(
    title: title ?? this.title,
    tagid: checkOptional(tagid, () => this.tagid),
    translate: checkOptional(translate, () => this.translate),
    watch: checkOptional(watch, () => this.watch),
    hide: checkOptional(hide, () => this.hide),
    defaultColor: checkOptional(defaultColor, () => this.defaultColor),
    colorCode: checkOptional(colorCode, () => this.colorCode),
    borderColor: checkOptional(borderColor, () => this.borderColor),
    textColor: checkOptional(textColor, () => this.textColor),
    tagWeight: checkOptional(tagWeight, () => this.tagWeight),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is EhUsertag && title == other.title && tagid == other.tagid && translate == other.translate && watch == other.watch && hide == other.hide && defaultColor == other.defaultColor && colorCode == other.colorCode && borderColor == other.borderColor && textColor == other.textColor && tagWeight == other.tagWeight;

  @override
  int get hashCode => title.hashCode ^ tagid.hashCode ^ translate.hashCode ^ watch.hashCode ^ hide.hashCode ^ defaultColor.hashCode ^ colorCode.hashCode ^ borderColor.hashCode ^ textColor.hashCode ^ tagWeight.hashCode;
}
