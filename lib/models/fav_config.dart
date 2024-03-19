import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class FavConfig {

  const FavConfig({
    this.lastIndex,
  });

  final int? lastIndex;

  factory FavConfig.fromJson(Map<String,dynamic> json) => FavConfig(
    lastIndex: json['lastIndex'] != null ? int.tryParse('${json['lastIndex']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'lastIndex': lastIndex
  };

  FavConfig clone() => FavConfig(
    lastIndex: lastIndex
  );


  FavConfig copyWith({
    Optional<int?>? lastIndex
  }) => FavConfig(
    lastIndex: checkOptional(lastIndex, () => this.lastIndex),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is FavConfig && lastIndex == other.lastIndex;

  @override
  int get hashCode => lastIndex.hashCode;
}
