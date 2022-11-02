import 'package:flutter/foundation.dart';

import 'favcat.dart';
import 'gallery_provider.dart';

@immutable
class GalleryList {
  const GalleryList({
    this.gallerys,
    this.next,
    this.prev,
    this.favList,
  });

  final List<GalleryProvider>? gallerys;
  final String? next;
  final String? prev;
  final List<Favcat>? favList;

  factory GalleryList.fromJson(Map<String, dynamic> json) => GalleryList(
      gallerys: json['gallerys'] != null
          ? (json['gallerys'] as List? ?? [])
              .map((e) => GalleryProvider.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      next: json['next'] != null ? json['next'] as String : null,
      prev: json['prev'] != null ? json['prev'] as String : null,
      favList: json['favList'] != null
          ? (json['favList'] as List? ?? [])
              .map((e) => Favcat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'gallerys': gallerys?.map((e) => e.toJson()).toList(),
        'next': next,
        'prev': prev,
        'favList': favList?.map((e) => e.toJson()).toList()
      };

  GalleryList clone() => GalleryList(
      gallerys: gallerys?.map((e) => e.clone()).toList(),
      next: next,
      prev: prev,
      favList: favList?.map((e) => e.clone()).toList());

  GalleryList copyWith(
          {List<GalleryProvider>? gallerys,
          String? next,
          String? prev,
          List<Favcat>? favList}) =>
      GalleryList(
        gallerys: gallerys ?? this.gallerys,
        next: next ?? this.next,
        prev: prev ?? this.prev,
        favList: favList ?? this.favList,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryList &&
          gallerys == other.gallerys &&
          next == other.next &&
          prev == other.prev &&
          favList == other.favList;

  @override
  int get hashCode =>
      gallerys.hashCode ^ next.hashCode ^ prev.hashCode ^ favList.hashCode;
}
