import 'package:flutter/foundation.dart';


@immutable
class FavConfig {
  
  const FavConfig({
    this.lastIndex,
  });

  final int? lastIndex;

  factory FavConfig.fromJson(Map<String,dynamic> json) => FavConfig(
    lastIndex: json['lastIndex'] != null ? json['lastIndex'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'lastIndex': lastIndex
  };

  FavConfig clone() => FavConfig(
    lastIndex: lastIndex
  );

    
  FavConfig copyWith({
    int? lastIndex
  }) => FavConfig(
    lastIndex: lastIndex ?? this.lastIndex,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is FavConfig && lastIndex == other.lastIndex;

  @override
  int get hashCode => lastIndex.hashCode;
}
