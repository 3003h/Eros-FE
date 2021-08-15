import 'package:flutter/foundation.dart';


@immutable
class Favcat {
  
  const Favcat({
    required this.favId,
    required this.favTitle,
    this.totNum,
    this.note,
  });

  final String favId;
  final String favTitle;
  final int? totNum;
  final String? note;

  factory Favcat.fromJson(Map<String,dynamic> json) => Favcat(
    favId: json['favId'] as String,
    favTitle: json['favTitle'] as String,
    totNum: json['totNum'] != null ? json['totNum'] as int : null,
    note: json['note'] != null ? json['note'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'favId': favId,
    'favTitle': favTitle,
    'totNum': totNum,
    'note': note
  };

  Favcat clone() => Favcat(
    favId: favId,
    favTitle: favTitle,
    totNum: totNum,
    note: note
  );

    
  Favcat copyWith({
    String? favId,
    String? favTitle,
    int? totNum,
    String? note
  }) => Favcat(
    favId: favId ?? this.favId,
    favTitle: favTitle ?? this.favTitle,
    totNum: totNum ?? this.totNum,
    note: note ?? this.note,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is Favcat && favId == other.favId && favTitle == other.favTitle && totNum == other.totNum && note == other.note;

  @override
  int get hashCode => favId.hashCode ^ favTitle.hashCode ^ totNum.hashCode ^ note.hashCode;
}
