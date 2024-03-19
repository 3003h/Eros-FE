import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    favId: json['favId'].toString(),
    favTitle: json['favTitle'].toString(),
    totNum: json['totNum'] != null ? int.tryParse('${json['totNum']}') ?? 0 : null,
    note: json['note']?.toString()
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
    Optional<int?>? totNum,
    Optional<String?>? note
  }) => Favcat(
    favId: favId ?? this.favId,
    favTitle: favTitle ?? this.favTitle,
    totNum: checkOptional(totNum, () => this.totNum),
    note: checkOptional(note, () => this.note),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Favcat && favId == other.favId && favTitle == other.favTitle && totNum == other.totNum && note == other.note;

  @override
  int get hashCode => favId.hashCode ^ favTitle.hashCode ^ totNum.hashCode ^ note.hashCode;
}
