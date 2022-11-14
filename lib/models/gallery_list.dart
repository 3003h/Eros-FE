import 'package:flutter/foundation.dart';
import 'gallery_provider.dart';
import 'favcat.dart';

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
    nextGid: json['nextGid'] != null ? json['nextGid'] as String : null,
    prevGid: json['prevGid'] != null ? json['prevGid'] as String : null,
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
    List<GalleryProvider>? gallerys,
    String? nextGid,
    String? prevGid,
    int? maxPage,
    int? nextPage,
    int? prevPage,
    List<Favcat>? favList
  }) => GalleryList(
    gallerys: gallerys ?? this.gallerys,
    nextGid: nextGid ?? this.nextGid,
    prevGid: prevGid ?? this.prevGid,
    maxPage: maxPage ?? this.maxPage,
    nextPage: nextPage ?? this.nextPage,
    prevPage: prevPage ?? this.prevPage,
    favList: favList ?? this.favList,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryList && gallerys == other.gallerys && nextGid == other.nextGid && prevGid == other.prevGid && maxPage == other.maxPage && nextPage == other.nextPage && prevPage == other.prevPage && favList == other.favList;

  @override
  int get hashCode => gallerys.hashCode ^ nextGid.hashCode ^ prevGid.hashCode ^ maxPage.hashCode ^ nextPage.hashCode ^ prevPage.hashCode ^ favList.hashCode;
}
