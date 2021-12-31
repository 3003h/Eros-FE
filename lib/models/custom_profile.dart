import 'package:flutter/foundation.dart';
import 'advance_search.dart';

@immutable
class CustomProfile {
  
  const CustomProfile({
    required this.uuid,
    required this.name,
    this.searchText,
    this.catsTypeValue,
    this.cats,
    this.advSearchTypeValue,
    this.advSearch,
  });

  final String uuid;
  final String name;
  final List<dynamic>? searchText;
  final String? catsTypeValue;
  final int? cats;
  final String? advSearchTypeValue;
  final AdvanceSearch? advSearch;

  factory CustomProfile.fromJson(Map<String,dynamic> json) => CustomProfile(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    searchText: json['searchText'] != null ? (json['searchText'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    catsTypeValue: json['catsTypeValue'] != null ? json['catsTypeValue'] as String : null,
    cats: json['cats'] != null ? json['cats'] as int : null,
    advSearchTypeValue: json['advSearchTypeValue'] != null ? json['advSearchTypeValue'] as String : null,
    advSearch: json['advSearch'] != null ? AdvanceSearch.fromJson(json['advSearch'] as Map<String, dynamic>) : null
  );
  
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'searchText': searchText?.map((e) => e.toString()).toList(),
    'catsTypeValue': catsTypeValue,
    'cats': cats,
    'advSearchTypeValue': advSearchTypeValue,
    'advSearch': advSearch?.toJson()
  };

  CustomProfile clone() => CustomProfile(
    uuid: uuid,
    name: name,
    searchText: searchText?.toList(),
    catsTypeValue: catsTypeValue,
    cats: cats,
    advSearchTypeValue: advSearchTypeValue,
    advSearch: advSearch?.clone()
  );

    
  CustomProfile copyWith({
    String? uuid,
    String? name,
    List<dynamic>? searchText,
    String? catsTypeValue,
    int? cats,
    String? advSearchTypeValue,
    AdvanceSearch? advSearch
  }) => CustomProfile(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    searchText: searchText ?? this.searchText,
    catsTypeValue: catsTypeValue ?? this.catsTypeValue,
    cats: cats ?? this.cats,
    advSearchTypeValue: advSearchTypeValue ?? this.advSearchTypeValue,
    advSearch: advSearch ?? this.advSearch,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is CustomProfile && uuid == other.uuid && name == other.name && searchText == other.searchText && catsTypeValue == other.catsTypeValue && cats == other.cats && advSearchTypeValue == other.advSearchTypeValue && advSearch == other.advSearch;

  @override
  int get hashCode => uuid.hashCode ^ name.hashCode ^ searchText.hashCode ^ catsTypeValue.hashCode ^ cats.hashCode ^ advSearchTypeValue.hashCode ^ advSearch.hashCode;
}
