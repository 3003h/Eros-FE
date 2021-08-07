import 'package:flutter/foundation.dart';
import 'eh_profile.dart';

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

  factory Uconfig.fromJson(Map<String, dynamic> json) => Uconfig(
      profilelist: (json['profilelist'] as List? ?? [])
          .map((e) => EhProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      profileSelected: json['profileSelected'] as String,
      nameDisplay:
          json['nameDisplay'] != null ? json['nameDisplay'] as int : null,
      thumbnailSize:
          json['thumbnailSize'] != null ? json['thumbnailSize'] as int : null,
      thumbnailRows:
          json['thumbnailRows'] != null ? json['thumbnailRows'] as int : null);

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
      thumbnailRows: thumbnailRows);

  Uconfig copyWith(
          {List<EhProfile>? profilelist,
          String? profileSelected,
          int? nameDisplay,
          int? thumbnailSize,
          int? thumbnailRows}) =>
      Uconfig(
        profilelist: profilelist ?? this.profilelist,
        profileSelected: profileSelected ?? this.profileSelected,
        nameDisplay: nameDisplay ?? this.nameDisplay,
        thumbnailSize: thumbnailSize ?? this.thumbnailSize,
        thumbnailRows: thumbnailRows ?? this.thumbnailRows,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Uconfig &&
          profilelist == other.profilelist &&
          profileSelected == other.profileSelected &&
          nameDisplay == other.nameDisplay &&
          thumbnailSize == other.thumbnailSize &&
          thumbnailRows == other.thumbnailRows;

  @override
  int get hashCode =>
      profilelist.hashCode ^
      profileSelected.hashCode ^
      nameDisplay.hashCode ^
      thumbnailSize.hashCode ^
      thumbnailRows.hashCode;
}
