import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    text: json['text']?.toString(),
    translat: json['Translat']?.toString(),
    color: json['color']?.toString(),
    backgrondColor: json['backgrondColor']?.toString()
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
    Optional<String?>? text,
    Optional<String?>? translat,
    Optional<String?>? color,
    Optional<String?>? backgrondColor
  }) => SimpleTag(
    text: checkOptional(text, () => this.text),
    translat: checkOptional(translat, () => this.translat),
    color: checkOptional(color, () => this.color),
    backgrondColor: checkOptional(backgrondColor, () => this.backgrondColor),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is SimpleTag && text == other.text && translat == other.translat && color == other.color && backgrondColor == other.backgrondColor;

  @override
  int get hashCode => text.hashCode ^ translat.hashCode ^ color.hashCode ^ backgrondColor.hashCode;
}
