import 'package:flutter/foundation.dart';
import 'eh_mytag_set.dart';
import 'eh_usertag.dart';

@immutable
class EhMytags {
  
  const EhMytags({
    required this.tagsets,
    this.canDelete,
    this.usertags,
  });

  final List<EhMytagSet> tagsets;
  final bool? canDelete;
  final List<EhUsertag>? usertags;

  factory EhMytags.fromJson(Map<String,dynamic> json) => EhMytags(
    tagsets: (json['tagsets'] as List? ?? []).map((e) => EhMytagSet.fromJson(e as Map<String, dynamic>)).toList(),
    canDelete: json['canDelete'] != null ? json['canDelete'] as bool : null,
    usertags: json['usertags'] != null ? (json['usertags'] as List? ?? []).map((e) => EhUsertag.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'tagsets': tagsets.map((e) => e.toJson()).toList(),
    'canDelete': canDelete,
    'usertags': usertags?.map((e) => e.toJson()).toList()
  };

  EhMytags clone() => EhMytags(
    tagsets: tagsets.map((e) => e.clone()).toList(),
    canDelete: canDelete,
    usertags: usertags?.map((e) => e.clone()).toList()
  );

    
  EhMytags copyWith({
    List<EhMytagSet>? tagsets,
    bool? canDelete,
    List<EhUsertag>? usertags
  }) => EhMytags(
    tagsets: tagsets ?? this.tagsets,
    canDelete: canDelete ?? this.canDelete,
    usertags: usertags ?? this.usertags,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhMytags && tagsets == other.tagsets && canDelete == other.canDelete && usertags == other.usertags;

  @override
  int get hashCode => tagsets.hashCode ^ canDelete.hashCode ^ usertags.hashCode;
}
