import 'package:flutter/foundation.dart';


@immutable
class Chapter {
  
  const Chapter({
    required this.page,
    this.author,
    this.title,
  });

  final int page;
  final String? author;
  final String? title;

  factory Chapter.fromJson(Map<String,dynamic> json) => Chapter(
    page: json['page'] as int,
    author: json['author'] != null ? json['author'] as String : null,
    title: json['title'] != null ? json['title'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'page': page,
    'author': author,
    'title': title
  };

  Chapter clone() => Chapter(
    page: page,
    author: author,
    title: title
  );

    
  Chapter copyWith({
    int? page,
    String? author,
    String? title
  }) => Chapter(
    page: page ?? this.page,
    author: author ?? this.author,
    title: title ?? this.title,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is Chapter && page == other.page && author == other.author && title == other.title;

  @override
  int get hashCode => page.hashCode ^ author.hashCode ^ title.hashCode;
}
