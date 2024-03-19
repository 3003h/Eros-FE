import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Uconfig {

  const Uconfig({
    required this.profilelist,
    required this.profileSelected,
    this.nameDisplay,
    this.thumbnailSize,
    this.thumbnailRows,
  });

  final List<EhProfile> profilelist;
  final String profileSelected;
  final int? nameDisplay;
  final int? thumbnailSize;
  final int? thumbnailRows;

  factory Uconfig.fromJson(Map<String,dynamic> json) => Uconfig(
    profilelist: (json['profilelist'] as List? ?? []).map((e) => EhProfile.fromJson(e as Map<String, dynamic>)).toList(),
    profileSelected: json['profileSelected'].toString(),
    nameDisplay: json['nameDisplay'] != null ? int.tryParse('${json['nameDisplay']}') ?? 0 : null,
    thumbnailSize: json['thumbnailSize'] != null ? int.tryParse('${json['thumbnailSize']}') ?? 0 : null,
    thumbnailRows: json['thumbnailRows'] != null ? int.tryParse('${json['thumbnailRows']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'profilelist': profilelist.map((e) => e.toJson()).toList(),
    'profileSelected': profileSelected,
    'nameDisplay': nameDisplay,
    'thumbnailSize': thumbnailSize,
    'thumbnailRows': thumbnailRows
  };

  Uconfig clone() => Uconfig(
    profilelist: profilelist.map((e) => e.clone()).toList(),
    profileSelected: profileSelected,
    nameDisplay: nameDisplay,
    thumbnailSize: thumbnailSize,
    thumbnailRows: thumbnailRows
  );


  Uconfig copyWith({
    List<EhProfile>? profilelist,
    String? profileSelected,
    Optional<int?>? nameDisplay,
    Optional<int?>? thumbnailSize,
    Optional<int?>? thumbnailRows
  }) => Uconfig(
    profilelist: profilelist ?? this.profilelist,
    profileSelected: profileSelected ?? this.profileSelected,
    nameDisplay: checkOptional(nameDisplay, () => this.nameDisplay),
    thumbnailSize: checkOptional(thumbnailSize, () => this.thumbnailSize),
    thumbnailRows: checkOptional(thumbnailRows, () => this.thumbnailRows),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Uconfig && profilelist == other.profilelist && profileSelected == other.profileSelected && nameDisplay == other.nameDisplay && thumbnailSize == other.thumbnailSize && thumbnailRows == other.thumbnailRows;

  @override
  int get hashCode => profilelist.hashCode ^ profileSelected.hashCode ^ nameDisplay.hashCode ^ thumbnailSize.hashCode ^ thumbnailRows.hashCode;
}
