import 'package:flutter/foundation.dart';
import 'advance_search.dart';

@immutable
class CustomProfile {
  
  const CustomProfile({
    required this.name,
    this.searchText,
    this.cats,
    this.advSearch,
  });

  final String name;
  final List<dynamic>? searchText;
  final int? cats;
  final AdvanceSearch? advSearch;

  factory CustomProfile.fromJson(Map<String,dynamic> json) => CustomProfile(
    name: json['name'] as String,
    searchText: json['search_text'] != null ? (json['search_text'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    cats: json['cats'] != null ? json['cats'] as int : null,
    advSearch: json['adv_search'] != null ? AdvanceSearch.fromJson(json['adv_search'] as Map<String, dynamic>) : null
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'search_text': searchText?.map((e) => e.toString()).toList(),
    'cats': cats,
    'adv_search': advSearch?.toJson()
  };

  CustomProfile clone() => CustomProfile(
    name: name,
    searchText: searchText?.toList(),
    cats: cats,
    advSearch: advSearch?.clone()
  );

    
  CustomProfile copyWith({
    String? name,
    List<dynamic>? searchText,
    int? cats,
    AdvanceSearch? advSearch
  }) => CustomProfile(
    name: name ?? this.name,
    searchText: searchText ?? this.searchText,
    cats: cats ?? this.cats,
    advSearch: advSearch ?? this.advSearch,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is CustomProfile && name == other.name && searchText == other.searchText && cats == other.cats && advSearch == other.advSearch;

  @override
  int get hashCode => name.hashCode ^ searchText.hashCode ^ cats.hashCode ^ advSearch.hashCode;
}
