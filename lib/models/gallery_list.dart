import 'package:flutter/foundation.dart';

import 'favcat.dart';
import 'gallery_provider.dart';

@immutable
class GalleryList {
  const GalleryList({
    this.gallerys,
    this.maxPage,
    this.nextPage,
    this.prevPage,
    this.favList,
  });

  final List<GalleryProvider>? gallerys;
  final int? maxPage;
  final int? nextPage;
  final int? prevPage;
  final List<Favcat>? favList;

  factory GalleryList.fromJson(Map<String, dynamic> json) => GalleryList(
      gallerys: json['gallerys'] != null
          ? (json['gallerys'] as List? ?? [])
              .map((e) => GalleryProvider.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      maxPage: json['maxPage'] != null ? json['maxPage'] as int : null,
      nextPage: json['nextPage'] != null ? json['nextPage'] as int : null,
      prevPage: json['prevPage'] != null ? json['prevPage'] as int : null,
      favList: json['favList'] != null
          ? (json['favList'] as List? ?? [])
              .map((e) => Favcat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'gallerys': gallerys?.map((e) => e.toJson()).toList(),
        'maxPage': maxPage,
        'nextPage': nextPage,
        'prevPage': prevPage,
        'favList': favList?.map((e) => e.toJson()).toList()
      };

  GalleryList clone() => GalleryList(
      gallerys: gallerys?.map((e) => e.clone()).toList(),
      maxPage: maxPage,
      nextPage: nextPage,
      prevPage: prevPage,
      favList: favList?.map((e) => e.clone()).toList());

  GalleryList copyWith(
          {List<GalleryProvider>? gallerys,
          int? maxPage,
          int? nextPage,
          int? prevPage,
          List<Favcat>? favList}) =>
      GalleryList(
        gallerys: gallerys ?? this.gallerys,
        maxPage: maxPage ?? this.maxPage,
        nextPage: nextPage ?? this.nextPage,
        prevPage: prevPage ?? this.prevPage,
        favList: favList ?? this.favList,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryList &&
          gallerys == other.gallerys &&
          maxPage == other.maxPage &&
          nextPage == other.nextPage &&
          prevPage == other.prevPage &&
          favList == other.favList;

  @override
  int get hashCode =>
      gallerys.hashCode ^
      maxPage.hashCode ^
      nextPage.hashCode ^
      prevPage.hashCode ^
      favList.hashCode;
}
