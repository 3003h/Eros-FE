import 'package:flutter/foundation.dart';


@immutable
class GalleryCommentSpan {
  
  const GalleryCommentSpan({
    this.type,
    this.style,
    this.text,
    this.translate,
    this.href,
    this.imageUrl,
  });

  final String? type;
  final String? style;
  final String? text;
  final String? translate;
  final String? href;
  final String? imageUrl;

  factory GalleryCommentSpan.fromJson(Map<String,dynamic> json) => GalleryCommentSpan(
    type: json['type'] != null ? json['type'] as String : null,
    style: json['style'] != null ? json['style'] as String : null,
    text: json['text'] != null ? json['text'] as String : null,
    translate: json['translate'] != null ? json['translate'] as String : null,
    href: json['href'] != null ? json['href'] as String : null,
    imageUrl: json['imageUrl'] != null ? json['imageUrl'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'style': style,
    'text': text,
    'translate': translate,
    'href': href,
    'imageUrl': imageUrl
  };

  GalleryCommentSpan clone() => GalleryCommentSpan(
    type: type,
    style: style,
    text: text,
    translate: translate,
    href: href,
    imageUrl: imageUrl
  );

    
  GalleryCommentSpan copyWith({
    String? type,
    String? style,
    String? text,
    String? translate,
    String? href,
    String? imageUrl
  }) => GalleryCommentSpan(
    type: type ?? this.type,
    style: style ?? this.style,
    text: text ?? this.text,
    translate: translate ?? this.translate,
    href: href ?? this.href,
    imageUrl: imageUrl ?? this.imageUrl,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryCommentSpan && type == other.type && style == other.style && text == other.text && translate == other.translate && href == other.href && imageUrl == other.imageUrl;

  @override
  int get hashCode => type.hashCode ^ style.hashCode ^ text.hashCode ^ translate.hashCode ^ href.hashCode ^ imageUrl.hashCode;
}
