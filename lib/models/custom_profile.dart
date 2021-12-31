import 'package:flutter/foundation.dart';
import 'advance_search.dart';

@immutable
class CustomProfile {
  
  const CustomProfile({
    required this.name,
    this.searchText,
    this.catsTypeValue,
    this.cats,
    this.advSearchTypeValue,
    this.advSearch,
  });

  final String name;
  final List<dynamic>? searchText;
  final String? catsTypeValue;
  final int? cats;
  final String? advSearchTypeValue;
  final AdvanceSearch? advSearch;

  factory CustomProfile.fromJson(Map<String,dynamic> json) => CustomProfile(
    name: json['name'] as String,
    searchText: json['searchText'] != null ? (json['searchText'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    catsTypeValue: json['catsTypeValue'] != null ? json['catsTypeValue'] as String : null,
    cats: json['cats'] != null ? json['cats'] as int : null,
    advSearchTypeValue: json['advSearchTypeValue'] != null ? json['advSearchTypeValue'] as String : null,
    advSearch: json['advSearch'] != null ? AdvanceSearch.fromJson(json['advSearch'] as Map<String, dynamic>) : null
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'searchText': searchText?.map((e) => e.toString()).toList(),
    'catsTypeValue': catsTypeValue,
    'cats': cats,
    'advSearchTypeValue': advSearchTypeValue,
    'advSearch': advSearch?.toJson()
  };

  CustomProfile clone() => CustomProfile(
    name: name,
    searchText: searchText?.toList(),
    catsTypeValue: catsTypeValue,
    cats: cats,
    advSearchTypeValue: advSearchTypeValue,
    advSearch: advSearch?.clone()
  );

    
  CustomProfile copyWith({
    String? name,
    List<dynamic>? searchText,
    String? catsTypeValue,
    int? cats,
    String? advSearchTypeValue,
    AdvanceSearch? advSearch
  }) => CustomProfile(
    name: name ?? this.name,
    searchText: searchText ?? this.searchText,
    catsTypeValue: catsTypeValue ?? this.catsTypeValue,
    cats: cats ?? this.cats,
    advSearchTypeValue: advSearchTypeValue ?? this.advSearchTypeValue,
    advSearch: advSearch ?? this.advSearch,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is CustomProfile && name == other.name && searchText == other.searchText && catsTypeValue == other.catsTypeValue && cats == other.cats && advSearchTypeValue == other.advSearchTypeValue && advSearch == other.advSearch;

  @override
  int get hashCode => name.hashCode ^ searchText.hashCode ^ catsTypeValue.hashCode ^ cats.hashCode ^ advSearchTypeValue.hashCode ^ advSearch.hashCode;
}
