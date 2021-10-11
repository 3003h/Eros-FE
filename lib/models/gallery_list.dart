import 'package:flutter/foundation.dart';

import 'favcat.dart';
import 'gallery_item.dart';

@immutable
class GalleryList {
  const GalleryList({
    this.gallerys,
    this.maxPage,
    this.nextPage,
    this.favList,
  });

  final List<GalleryItem>? gallerys;
  final int? maxPage;
  final int? nextPage;
  final List<Favcat>? favList;

  factory GalleryList.fromJson(Map<String, dynamic> json) => GalleryList(
      gallerys: json['gallerys'] != null
          ? (json['gallerys'] as List? ?? [])
              .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      maxPage: json['maxPage'] != null ? json['maxPage'] as int : null,
      nextPage: json['nextPage'] != null ? json['nextPage'] as int : null,
      favList: json['favList'] != null
          ? (json['favList'] as List? ?? [])
              .map((e) => Favcat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'gallerys': gallerys?.map((e) => e.toJson()).toList(),
        'maxPage': maxPage,
        'nextPage': nextPage,
        'favList': favList?.map((e) => e.toJson()).toList()
      };

  GalleryList clone() => GalleryList(
      gallerys: gallerys?.map((e) => e.clone()).toList(),
      maxPage: maxPage,
      nextPage: nextPage,
      favList: favList?.map((e) => e.clone()).toList());

  GalleryList copyWith(
          {List<GalleryItem>? gallerys,
          int? maxPage,
          int? nextPage,
          List<Favcat>? favList}) =>
      GalleryList(
        gallerys: gallerys ?? this.gallerys,
        maxPage: maxPage ?? this.maxPage,
        nextPage: nextPage ?? this.nextPage,
        favList: favList ?? this.favList,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryList &&
          gallerys == other.gallerys &&
          maxPage == other.maxPage &&
          nextPage == other.nextPage &&
          favList == other.favList;

  @override
  int get hashCode =>
      gallerys.hashCode ^
      maxPage.hashCode ^
      nextPage.hashCode ^
      favList.hashCode;
}
