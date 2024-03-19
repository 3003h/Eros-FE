import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    this.hideTab,
    this.aggregateGroups,
    this.lastEditTime,
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
  final bool? hideTab;
  final List<String>? aggregateGroups;
  final int? lastEditTime;

  factory CustomProfile.fromJson(Map<String,dynamic> json) => CustomProfile(
    uuid: json['uuid'].toString(),
    name: json['name'].toString(),
    searchText: json['searchText'] != null ? (json['searchText'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    listTypeValue: json['listTypeValue']?.toString(),
    catsTypeValue: json['catsTypeValue']?.toString(),
    cats: json['cats'] != null ? int.tryParse('${json['cats']}') ?? 0 : null,
    enableAdvance: json['enableAdvance'] != null ? bool.tryParse('${json['enableAdvance']}', caseSensitive: false) ?? false : null,
    advSearchTypeValue: json['advSearchTypeValue']?.toString(),
    advSearch: json['advSearch'] != null ? AdvanceSearch.fromJson(json['advSearch'] as Map<String, dynamic>) : null,
    listModeValue: json['listModeValue']?.toString(),
    hideTab: json['hideTab'] != null ? bool.tryParse('${json['hideTab']}', caseSensitive: false) ?? false : null,
    aggregateGroups: json['aggregateGroups'] != null ? (json['aggregateGroups'] as List? ?? []).map((e) => e as String).toList() : null,
    lastEditTime: json['lastEditTime'] != null ? int.tryParse('${json['lastEditTime']}') ?? 0 : null
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
    'listModeValue': listModeValue,
    'hideTab': hideTab,
    'aggregateGroups': aggregateGroups?.map((e) => e.toString()).toList(),
    'lastEditTime': lastEditTime
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
    listModeValue: listModeValue,
    hideTab: hideTab,
    aggregateGroups: aggregateGroups?.toList(),
    lastEditTime: lastEditTime
  );


  CustomProfile copyWith({
    String? uuid,
    String? name,
    Optional<List<dynamic>?>? searchText,
    Optional<String?>? listTypeValue,
    Optional<String?>? catsTypeValue,
    Optional<int?>? cats,
    Optional<bool?>? enableAdvance,
    Optional<String?>? advSearchTypeValue,
    Optional<AdvanceSearch?>? advSearch,
    Optional<String?>? listModeValue,
    Optional<bool?>? hideTab,
    Optional<List<String>?>? aggregateGroups,
    Optional<int?>? lastEditTime
  }) => CustomProfile(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    searchText: checkOptional(searchText, () => this.searchText),
    listTypeValue: checkOptional(listTypeValue, () => this.listTypeValue),
    catsTypeValue: checkOptional(catsTypeValue, () => this.catsTypeValue),
    cats: checkOptional(cats, () => this.cats),
    enableAdvance: checkOptional(enableAdvance, () => this.enableAdvance),
    advSearchTypeValue: checkOptional(advSearchTypeValue, () => this.advSearchTypeValue),
    advSearch: checkOptional(advSearch, () => this.advSearch),
    listModeValue: checkOptional(listModeValue, () => this.listModeValue),
    hideTab: checkOptional(hideTab, () => this.hideTab),
    aggregateGroups: checkOptional(aggregateGroups, () => this.aggregateGroups),
    lastEditTime: checkOptional(lastEditTime, () => this.lastEditTime),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is CustomProfile && uuid == other.uuid && name == other.name && searchText == other.searchText && listTypeValue == other.listTypeValue && catsTypeValue == other.catsTypeValue && cats == other.cats && enableAdvance == other.enableAdvance && advSearchTypeValue == other.advSearchTypeValue && advSearch == other.advSearch && listModeValue == other.listModeValue && hideTab == other.hideTab && aggregateGroups == other.aggregateGroups && lastEditTime == other.lastEditTime;

  @override
  int get hashCode => uuid.hashCode ^ name.hashCode ^ searchText.hashCode ^ listTypeValue.hashCode ^ catsTypeValue.hashCode ^ cats.hashCode ^ enableAdvance.hashCode ^ advSearchTypeValue.hashCode ^ advSearch.hashCode ^ listModeValue.hashCode ^ hideTab.hashCode ^ aggregateGroups.hashCode ^ lastEditTime.hashCode;
}
