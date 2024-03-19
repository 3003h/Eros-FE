import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class GalleryList {

  const GalleryList({
    this.gallerys,
    this.nextGid,
    this.prevGid,
    this.maxPage,
    this.nextPage,
    this.prevPage,
    this.favList,
  });

  final List<GalleryProvider>? gallerys;
  final String? nextGid;
  final String? prevGid;
  final int? maxPage;
  final int? nextPage;
  final int? prevPage;
  final List<Favcat>? favList;

  factory GalleryList.fromJson(Map<String,dynamic> json) => GalleryList(
    gallerys: json['gallerys'] != null ? (json['gallerys'] as List? ?? []).map((e) => GalleryProvider.fromJson(e as Map<String, dynamic>)).toList() : null,
    nextGid: json['nextGid']?.toString(),
    prevGid: json['prevGid']?.toString(),
    maxPage: json['maxPage'] != null ? json['maxPage'] as int : null,
    nextPage: json['nextPage'] != null ? json['nextPage'] as int : null,
    prevPage: json['prevPage'] != null ? json['prevPage'] as int : null,
    favList: json['favList'] != null ? (json['favList'] as List? ?? []).map((e) => Favcat.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'gallerys': gallerys?.map((e) => e.toJson()).toList(),
    'nextGid': nextGid,
    'prevGid': prevGid,
    'maxPage': maxPage,
    'nextPage': nextPage,
    'prevPage': prevPage,
    'favList': favList?.map((e) => e.toJson()).toList()
  };

  GalleryList clone() => GalleryList(
    gallerys: gallerys?.map((e) => e.clone()).toList(),
    nextGid: nextGid,
    prevGid: prevGid,
    maxPage: maxPage,
    nextPage: nextPage,
    prevPage: prevPage,
    favList: favList?.map((e) => e.clone()).toList()
  );


  GalleryList copyWith({
    Optional<List<GalleryProvider>?>? gallerys,
    Optional<String?>? nextGid,
    Optional<String?>? prevGid,
    Optional<int?>? maxPage,
    Optional<int?>? nextPage,
    Optional<int?>? prevPage,
    Optional<List<Favcat>?>? favList
  }) => GalleryList(
    gallerys: checkOptional(gallerys, () => this.gallerys),
    nextGid: checkOptional(nextGid, () => this.nextGid),
    prevGid: checkOptional(prevGid, () => this.prevGid),
    maxPage: checkOptional(maxPage, () => this.maxPage),
    nextPage: checkOptional(nextPage, () => this.nextPage),
    prevPage: checkOptional(prevPage, () => this.prevPage),
    favList: checkOptional(favList, () => this.favList),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryList && gallerys == other.gallerys && nextGid == other.nextGid && prevGid == other.prevGid && maxPage == other.maxPage && nextPage == other.nextPage && prevPage == other.prevPage && favList == other.favList;

  @override
  int get hashCode => gallerys.hashCode ^ nextGid.hashCode ^ prevGid.hashCode ^ maxPage.hashCode ^ nextPage.hashCode ^ prevPage.hashCode ^ favList.hashCode;
}
