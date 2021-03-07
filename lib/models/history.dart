import 'package:flutter/foundation.dart';

import 'gallery_item.dart';

@immutable
class History {
  const History({
    this.history,
  });

  final List<GalleryItem>? history;

  factory History.fromJson(Map<String, dynamic> json) => History(
      history: json['history'] != null
          ? (json['history'] as List)
              .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null);

  Map<String, dynamic> toJson() =>
      {'history': history?.map((e) => e.toJson()).toList()};

  History clone() => History(history: history?.map((e) => e.clone()).toList());

  History copyWith({List<GalleryItem>? history}) => History(
        history: history ?? this.history,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is History && history == other.history;

  @override
  int get hashCode => history.hashCode;
}
