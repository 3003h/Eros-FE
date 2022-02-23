import 'package:flutter/foundation.dart';


@immutable
class EhUsertag {
  
  const EhUsertag({
    required this.title,
    this.translate,
    this.watch,
    this.hide,
    this.colorCode,
    this.borderColor,
    this.textColor,
    this.tagWeight,
  });

  final String title;
  final String? translate;
  final bool? watch;
  final bool? hide;
  final String? colorCode;
  final String? borderColor;
  final String? textColor;
  final String? tagWeight;

  factory EhUsertag.fromJson(Map<String,dynamic> json) => EhUsertag(
    title: json['title'] as String,
    translate: json['translate'] != null ? json['translate'] as String : null,
    watch: json['watch'] != null ? json['watch'] as bool : null,
    hide: json['hide'] != null ? json['hide'] as bool : null,
    colorCode: json['colorCode'] != null ? json['colorCode'] as String : null,
    borderColor: json['borderColor'] != null ? json['borderColor'] as String : null,
    textColor: json['textColor'] != null ? json['textColor'] as String : null,
    tagWeight: json['tagWeight'] != null ? json['tagWeight'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'translate': translate,
    'watch': watch,
    'hide': hide,
    'colorCode': colorCode,
    'borderColor': borderColor,
    'textColor': textColor,
    'tagWeight': tagWeight
  };

  EhUsertag clone() => EhUsertag(
    title: title,
    translate: translate,
    watch: watch,
    hide: hide,
    colorCode: colorCode,
    borderColor: borderColor,
    textColor: textColor,
    tagWeight: tagWeight
  );

    
  EhUsertag copyWith({
    String? title,
    String? translate,
    bool? watch,
    bool? hide,
    String? colorCode,
    String? borderColor,
    String? textColor,
    String? tagWeight
  }) => EhUsertag(
    title: title ?? this.title,
    translate: translate ?? this.translate,
    watch: watch ?? this.watch,
    hide: hide ?? this.hide,
    colorCode: colorCode ?? this.colorCode,
    borderColor: borderColor ?? this.borderColor,
    textColor: textColor ?? this.textColor,
    tagWeight: tagWeight ?? this.tagWeight,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhUsertag && title == other.title && translate == other.translate && watch == other.watch && hide == other.hide && colorCode == other.colorCode && borderColor == other.borderColor && textColor == other.textColor && tagWeight == other.tagWeight;

  @override
  int get hashCode => title.hashCode ^ translate.hashCode ^ watch.hashCode ^ hide.hashCode ^ colorCode.hashCode ^ borderColor.hashCode ^ textColor.hashCode ^ tagWeight.hashCode;
}
