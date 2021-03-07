import 'package:flutter/foundation.dart';


@immutable
class GalleryCommentSpan {
  
  const GalleryCommentSpan({
    this.type,
    this.style,
    this.text,
    this.href,
    this.imageUrl,
  });

  final String? type;
  final String? style;
  final String? text;
  final String? href;
  final String? imageUrl;

  factory GalleryCommentSpan.fromJson(Map<String,dynamic> json) => GalleryCommentSpan(
    type: json['type'] != null ? json['type'] as String : null,
    style: json['style'] != null ? json['style'] as String : null,
    text: json['text'] != null ? json['text'] as String : null,
    href: json['href'] != null ? json['href'] as String : null,
    imageUrl: json['image_url'] != null ? json['image_url'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'style': style,
    'text': text,
    'href': href,
    'image_url': imageUrl
  };

  GalleryCommentSpan clone() => GalleryCommentSpan(
    type: type,
    style: style,
    text: text,
    href: href,
    imageUrl: imageUrl
  );

    
  GalleryCommentSpan copyWith({
    String? type,
    String? style,
    String? text,
    String? href,
    String? imageUrl
  }) => GalleryCommentSpan(
    type: type ?? this.type,
    style: style ?? this.style,
    text: text ?? this.text,
    href: href ?? this.href,
    imageUrl: imageUrl ?? this.imageUrl,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryCommentSpan && type == other.type && style == other.style && text == other.text && href == other.href && imageUrl == other.imageUrl;

  @override
  int get hashCode => type.hashCode ^ style.hashCode ^ text.hashCode ^ href.hashCode ^ imageUrl.hashCode;
}
