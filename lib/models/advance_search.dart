import 'package:flutter/foundation.dart';


@immutable
class AdvanceSearch {
  
  const AdvanceSearch({
    required this.searchGalleryName,
    required this.searchGalleryTags,
    required this.searchGalleryDesc,
    required this.searchToreenFilenames,
    required this.onlyShowWhithTorrents,
    required this.searchLowPowerTags,
    required this.searchDownvotedTags,
    required this.searchExpunged,
    required this.searchWithminRating,
    required this.minRating,
    required this.searchBetweenpage,
    required this.startPage,
    required this.endPage,
    required this.disableDFLanguage,
    required this.disableDFUploader,
    required this.disableDFTags,
    required this.favSearchName,
    required this.favSearchTags,
    required this.favSearchNote,
  });

  final bool searchGalleryName;
  final bool searchGalleryTags;
  final bool searchGalleryDesc;
  final bool searchToreenFilenames;
  final bool onlyShowWhithTorrents;
  final bool searchLowPowerTags;
  final bool searchDownvotedTags;
  final bool searchExpunged;
  final bool searchWithminRating;
  final int minRating;
  final bool searchBetweenpage;
  final String startPage;
  final String endPage;
  final bool disableDFLanguage;
  final bool disableDFUploader;
  final bool disableDFTags;
  final bool favSearchName;
  final bool favSearchTags;
  final bool favSearchNote;

  factory AdvanceSearch.fromJson(Map<String,dynamic> json) => AdvanceSearch(
    searchGalleryName: json['searchGalleryName'] as bool,
    searchGalleryTags: json['searchGalleryTags'] as bool,
    searchGalleryDesc: json['searchGalleryDesc'] as bool,
    searchToreenFilenames: json['searchToreenFilenames'] as bool,
    onlyShowWhithTorrents: json['onlyShowWhithTorrents'] as bool,
    searchLowPowerTags: json['searchLowPowerTags'] as bool,
    searchDownvotedTags: json['searchDownvotedTags'] as bool,
    searchExpunged: json['searchExpunged'] as bool,
    searchWithminRating: json['searchWithminRating'] as bool,
    minRating: json['minRating'] as int,
    searchBetweenpage: json['searchBetweenpage'] as bool,
    startPage: json['startPage'] as String,
    endPage: json['endPage'] as String,
    disableDFLanguage: json['disableDFLanguage'] as bool,
    disableDFUploader: json['disableDFUploader'] as bool,
    disableDFTags: json['disableDFTags'] as bool,
    favSearchName: json['favSearchName'] as bool,
    favSearchTags: json['favSearchTags'] as bool,
    favSearchNote: json['favSearchNote'] as bool
  );
  
  Map<String, dynamic> toJson() => {
    'searchGalleryName': searchGalleryName,
    'searchGalleryTags': searchGalleryTags,
    'searchGalleryDesc': searchGalleryDesc,
    'searchToreenFilenames': searchToreenFilenames,
    'onlyShowWhithTorrents': onlyShowWhithTorrents,
    'searchLowPowerTags': searchLowPowerTags,
    'searchDownvotedTags': searchDownvotedTags,
    'searchExpunged': searchExpunged,
    'searchWithminRating': searchWithminRating,
    'minRating': minRating,
    'searchBetweenpage': searchBetweenpage,
    'startPage': startPage,
    'endPage': endPage,
    'disableDFLanguage': disableDFLanguage,
    'disableDFUploader': disableDFUploader,
    'disableDFTags': disableDFTags,
    'favSearchName': favSearchName,
    'favSearchTags': favSearchTags,
    'favSearchNote': favSearchNote
  };

  AdvanceSearch clone() => AdvanceSearch(
    searchGalleryName: searchGalleryName,
    searchGalleryTags: searchGalleryTags,
    searchGalleryDesc: searchGalleryDesc,
    searchToreenFilenames: searchToreenFilenames,
    onlyShowWhithTorrents: onlyShowWhithTorrents,
    searchLowPowerTags: searchLowPowerTags,
    searchDownvotedTags: searchDownvotedTags,
    searchExpunged: searchExpunged,
    searchWithminRating: searchWithminRating,
    minRating: minRating,
    searchBetweenpage: searchBetweenpage,
    startPage: startPage,
    endPage: endPage,
    disableDFLanguage: disableDFLanguage,
    disableDFUploader: disableDFUploader,
    disableDFTags: disableDFTags,
    favSearchName: favSearchName,
    favSearchTags: favSearchTags,
    favSearchNote: favSearchNote
  );

    
  AdvanceSearch copyWith({
    bool? searchGalleryName,
    bool? searchGalleryTags,
    bool? searchGalleryDesc,
    bool? searchToreenFilenames,
    bool? onlyShowWhithTorrents,
    bool? searchLowPowerTags,
    bool? searchDownvotedTags,
    bool? searchExpunged,
    bool? searchWithminRating,
    int? minRating,
    bool? searchBetweenpage,
    String? startPage,
    String? endPage,
    bool? disableDFLanguage,
    bool? disableDFUploader,
    bool? disableDFTags,
    bool? favSearchName,
    bool? favSearchTags,
    bool? favSearchNote
  }) => AdvanceSearch(
    searchGalleryName: searchGalleryName ?? this.searchGalleryName,
    searchGalleryTags: searchGalleryTags ?? this.searchGalleryTags,
    searchGalleryDesc: searchGalleryDesc ?? this.searchGalleryDesc,
    searchToreenFilenames: searchToreenFilenames ?? this.searchToreenFilenames,
    onlyShowWhithTorrents: onlyShowWhithTorrents ?? this.onlyShowWhithTorrents,
    searchLowPowerTags: searchLowPowerTags ?? this.searchLowPowerTags,
    searchDownvotedTags: searchDownvotedTags ?? this.searchDownvotedTags,
    searchExpunged: searchExpunged ?? this.searchExpunged,
    searchWithminRating: searchWithminRating ?? this.searchWithminRating,
    minRating: minRating ?? this.minRating,
    searchBetweenpage: searchBetweenpage ?? this.searchBetweenpage,
    startPage: startPage ?? this.startPage,
    endPage: endPage ?? this.endPage,
    disableDFLanguage: disableDFLanguage ?? this.disableDFLanguage,
    disableDFUploader: disableDFUploader ?? this.disableDFUploader,
    disableDFTags: disableDFTags ?? this.disableDFTags,
    favSearchName: favSearchName ?? this.favSearchName,
    favSearchTags: favSearchTags ?? this.favSearchTags,
    favSearchNote: favSearchNote ?? this.favSearchNote,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is AdvanceSearch && searchGalleryName == other.searchGalleryName && searchGalleryTags == other.searchGalleryTags && searchGalleryDesc == other.searchGalleryDesc && searchToreenFilenames == other.searchToreenFilenames && onlyShowWhithTorrents == other.onlyShowWhithTorrents && searchLowPowerTags == other.searchLowPowerTags && searchDownvotedTags == other.searchDownvotedTags && searchExpunged == other.searchExpunged && searchWithminRating == other.searchWithminRating && minRating == other.minRating && searchBetweenpage == other.searchBetweenpage && startPage == other.startPage && endPage == other.endPage && disableDFLanguage == other.disableDFLanguage && disableDFUploader == other.disableDFUploader && disableDFTags == other.disableDFTags && favSearchName == other.favSearchName && favSearchTags == other.favSearchTags && favSearchNote == other.favSearchNote;

  @override
  int get hashCode => searchGalleryName.hashCode ^ searchGalleryTags.hashCode ^ searchGalleryDesc.hashCode ^ searchToreenFilenames.hashCode ^ onlyShowWhithTorrents.hashCode ^ searchLowPowerTags.hashCode ^ searchDownvotedTags.hashCode ^ searchExpunged.hashCode ^ searchWithminRating.hashCode ^ minRating.hashCode ^ searchBetweenpage.hashCode ^ startPage.hashCode ^ endPage.hashCode ^ disableDFLanguage.hashCode ^ disableDFUploader.hashCode ^ disableDFTags.hashCode ^ favSearchName.hashCode ^ favSearchTags.hashCode ^ favSearchNote.hashCode;
}
