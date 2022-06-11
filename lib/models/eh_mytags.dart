import 'package:flutter/foundation.dart';

import 'eh_mytag_set.dart';
import 'eh_usertag.dart';

@immutable
class EhMytags {
  const EhMytags({
    required this.tagsets,
    this.canDelete,
    this.usertags,
    this.apikey,
    this.apiuid,
  });

  final List<EhMytagSet> tagsets;
  final bool? canDelete;
  final List<EhUsertag>? usertags;
  final String? apikey;
  final String? apiuid;

  factory EhMytags.fromJson(Map<String, dynamic> json) => EhMytags(
      tagsets: (json['tagsets'] as List? ?? [])
          .map((e) => EhMytagSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      canDelete: json['canDelete'] != null ? json['canDelete'] as bool : null,
      usertags: json['usertags'] != null
          ? (json['usertags'] as List? ?? [])
              .map((e) => EhUsertag.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      apikey: json['apikey'] != null ? json['apikey'] as String : null,
      apiuid: json['apiuid'] != null ? json['apiuid'] as String : null);

  Map<String, dynamic> toJson() => {
        'tagsets': tagsets.map((e) => e.toJson()).toList(),
        'canDelete': canDelete,
        'usertags': usertags?.map((e) => e.toJson()).toList(),
        'apikey': apikey,
        'apiuid': apiuid
      };

  EhMytags clone() => EhMytags(
      tagsets: tagsets.map((e) => e.clone()).toList(),
      canDelete: canDelete,
      usertags: usertags?.map((e) => e.clone()).toList(),
      apikey: apikey,
      apiuid: apiuid);

  EhMytags copyWith(
          {List<EhMytagSet>? tagsets,
          bool? canDelete,
          List<EhUsertag>? usertags,
          String? apikey,
          String? apiuid}) =>
      EhMytags(
        tagsets: tagsets ?? this.tagsets,
        canDelete: canDelete ?? this.canDelete,
        usertags: usertags ?? this.usertags,
        apikey: apikey ?? this.apikey,
        apiuid: apiuid ?? this.apiuid,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EhMytags &&
          tagsets == other.tagsets &&
          canDelete == other.canDelete &&
          usertags == other.usertags &&
          apikey == other.apikey &&
          apiuid == other.apiuid;

  @override
  int get hashCode =>
      tagsets.hashCode ^
      canDelete.hashCode ^
      usertags.hashCode ^
      apikey.hashCode ^
      apiuid.hashCode;
}
