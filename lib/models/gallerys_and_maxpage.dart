import 'package:flutter/foundation.dart';
import 'gallery_item.dart';

@immutable
class GallerysAndMaxpage {
  
  const GallerysAndMaxpage({
    this.gallerys,
    this.maxPage,
  });

  final List<GalleryItem>? gallerys;
  final int? maxPage;

  factory GallerysAndMaxpage.fromJson(Map<String,dynamic> json) => GallerysAndMaxpage(
    gallerys: json['gallerys'] != null ? (json['gallerys'] as List? ?? []).map((e) => GalleryItem.fromJson(e as Map<String, dynamic>)).toList() : null,
    maxPage: json['maxPage'] != null ? json['maxPage'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'gallerys': gallerys?.map((e) => e.toJson()).toList(),
    'maxPage': maxPage
  };

  GallerysAndMaxpage clone() => GallerysAndMaxpage(
    gallerys: gallerys?.map((e) => e.clone()).toList(),
    maxPage: maxPage
  );

    
  GallerysAndMaxpage copyWith({
    List<GalleryItem>? gallerys,
    int? maxPage
  }) => GallerysAndMaxpage(
    gallerys: gallerys ?? this.gallerys,
    maxPage: maxPage ?? this.maxPage,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GallerysAndMaxpage && gallerys == other.gallerys && maxPage == other.maxPage;

  @override
  int get hashCode => gallerys.hashCode ^ maxPage.hashCode;
}
