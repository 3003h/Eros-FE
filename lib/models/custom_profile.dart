import 'package:flutter/foundation.dart';
import 'advance_search.dart';

@immutable
class CustomProfile {
  
  const CustomProfile({
    required this.uuid,
    required this.name,
    this.searchText,
    this.listTypeValue,
    this.catsTypeValue,
    this.cats,
    this.enableAdvance,
    this.advSearchTypeValue,
    this.advSearch,
    this.listModeValue,
  });

  final String uuid;
  final String name;
  final List<dynamic>? searchText;
  final String? listTypeValue;
  final String? catsTypeValue;
  final int? cats;
  final bool? enableAdvance;
  final String? advSearchTypeValue;
  final AdvanceSearch? advSearch;
  final String? listModeValue;

  factory CustomProfile.fromJson(Map<String,dynamic> json) => CustomProfile(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    searchText: json['searchText'] != null ? (json['searchText'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    listTypeValue: json['listTypeValue'] != null ? json['listTypeValue'] as String : null,
    catsTypeValue: json['catsTypeValue'] != null ? json['catsTypeValue'] as String : null,
    cats: json['cats'] != null ? json['cats'] as int : null,
    enableAdvance: json['enableAdvance'] != null ? json['enableAdvance'] as bool : null,
    advSearchTypeValue: json['advSearchTypeValue'] != null ? json['advSearchTypeValue'] as String : null,
    advSearch: json['advSearch'] != null ? AdvanceSearch.fromJson(json['advSearch'] as Map<String, dynamic>) : null,
    listModeValue: json['listModeValue'] != null ? json['listModeValue'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'searchText': searchText?.map((e) => e.toString()).toList(),
    'listTypeValue': listTypeValue,
    'catsTypeValue': catsTypeValue,
    'cats': cats,
    'enableAdvance': enableAdvance,
    'advSearchTypeValue': advSearchTypeValue,
    'advSearch': advSearch?.toJson(),
    'listModeValue': listModeValue
  };

  CustomProfile clone() => CustomProfile(
    uuid: uuid,
    name: name,
    searchText: searchText?.toList(),
    listTypeValue: listTypeValue,
    catsTypeValue: catsTypeValue,
    cats: cats,
    enableAdvance: enableAdvance,
    advSearchTypeValue: advSearchTypeValue,
    advSearch: advSearch?.clone(),
    listModeValue: listModeValue
  );

    
  CustomProfile copyWith({
    String? uuid,
    String? name,
    List<dynamic>? searchText,
    String? listTypeValue,
    String? catsTypeValue,
    int? cats,
    bool? enableAdvance,
    String? advSearchTypeValue,
    AdvanceSearch? advSearch,
    String? listModeValue
  }) => CustomProfile(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    searchText: searchText ?? this.searchText,
    listTypeValue: listTypeValue ?? this.listTypeValue,
    catsTypeValue: catsTypeValue ?? this.catsTypeValue,
    cats: cats ?? this.cats,
    enableAdvance: enableAdvance ?? this.enableAdvance,
    advSearchTypeValue: advSearchTypeValue ?? this.advSearchTypeValue,
    advSearch: advSearch ?? this.advSearch,
    listModeValue: listModeValue ?? this.listModeValue,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is CustomProfile && uuid == other.uuid && name == other.name && searchText == other.searchText && listTypeValue == other.listTypeValue && catsTypeValue == other.catsTypeValue && cats == other.cats && enableAdvance == other.enableAdvance && advSearchTypeValue == other.advSearchTypeValue && advSearch == other.advSearch && listModeValue == other.listModeValue;

  @override
  int get hashCode => uuid.hashCode ^ name.hashCode ^ searchText.hashCode ^ listTypeValue.hashCode ^ catsTypeValue.hashCode ^ cats.hashCode ^ enableAdvance.hashCode ^ advSearchTypeValue.hashCode ^ advSearch.hashCode ^ listModeValue.hashCode;
}
