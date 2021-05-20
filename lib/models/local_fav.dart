import 'package:flutter/foundation.dart';

import 'gallery_item.dart';

@immutable
class LocalFav {
  const LocalFav({
    this.gallerys,
  });

  final List<GalleryItem>? gallerys;

  factory LocalFav.fromJson(Map<String, dynamic> json) => LocalFav(
      gallerys: json['gallerys'] != null
          ? (json['gallerys'] as List? ?? [])
              .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() =>
      {'gallerys': gallerys?.map((e) => e.toJson()).toList()};

  LocalFav clone() =>
      LocalFav(gallerys: gallerys?.map((e) => e.clone()).toList());

  LocalFav copyWith({List<GalleryItem>? gallerys}) => LocalFav(
        gallerys: gallerys ?? this.gallerys,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalFav && gallerys == other.gallerys;

  @override
  int get hashCode => gallerys.hashCode;
}
