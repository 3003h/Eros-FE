import 'package:flutter/foundation.dart';


@immutable
class SimpleTag {
  
  const SimpleTag({
    this.text,
    this.translat,
    this.color,
    this.backgrondColor,
  });

  final String? text;
  final String? translat;
  final String? color;
  final String? backgrondColor;

  factory SimpleTag.fromJson(Map<String,dynamic> json) => SimpleTag(
    text: json['text'] != null ? json['text'] as String : null,
    translat: json['Translat'] != null ? json['Translat'] as String : null,
    color: json['color'] != null ? json['color'] as String : null,
    backgrondColor: json['backgrondColor'] != null ? json['backgrondColor'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'text': text,
    'Translat': translat,
    'color': color,
    'backgrondColor': backgrondColor
  };

  SimpleTag clone() => SimpleTag(
    text: text,
    translat: translat,
    color: color,
    backgrondColor: backgrondColor
  );

    
  SimpleTag copyWith({
    String? text,
    String? translat,
    String? color,
    String? backgrondColor
  }) => SimpleTag(
    text: text ?? this.text,
    translat: translat ?? this.translat,
    color: color ?? this.color,
    backgrondColor: backgrondColor ?? this.backgrondColor,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is SimpleTag && text == other.text && translat == other.translat && color == other.color && backgrondColor == other.backgrondColor;

  @override
  int get hashCode => text.hashCode ^ translat.hashCode ^ color.hashCode ^ backgrondColor.hashCode;
}
