import 'package:flutter/foundation.dart';


@immutable
class Favcat {
  
  const Favcat({
    required this.favId,
    required this.favTitle,
  });

  final String favId;
  final String favTitle;

  factory Favcat.fromJson(Map<String,dynamic> json) => Favcat(
    favId: json['favId'] as String,
    favTitle: json['favTitle'] as String
  );
  
  Map<String, dynamic> toJson() => {
    'favId': favId,
    'favTitle': favTitle
  };

  Favcat clone() => Favcat(
    favId: favId,
    favTitle: favTitle
  );

    
  Favcat copyWith({
    String? favId,
    String? favTitle
  }) => Favcat(
    favId: favId ?? this.favId,
    favTitle: favTitle ?? this.favTitle,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is Favcat && favId == other.favId && favTitle == other.favTitle;

  @override
  int get hashCode => favId.hashCode ^ favTitle.hashCode;
}
