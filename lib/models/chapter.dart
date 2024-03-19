import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    page: int.tryParse('${json['page']}') ?? 0,
    author: json['author']?.toString(),
    title: json['title']?.toString()
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
    Optional<String?>? author,
    Optional<String?>? title
  }) => Chapter(
    page: page ?? this.page,
    author: checkOptional(author, () => this.author),
    title: checkOptional(title, () => this.title),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Chapter && page == other.page && author == other.author && title == other.title;

  @override
  int get hashCode => page.hashCode ^ author.hashCode ^ title.hashCode;
}
