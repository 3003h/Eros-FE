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
    searchGalleryName: json['search_gallery_name'] as bool,
    searchGalleryTags: json['search_gallery_tags'] as bool,
    searchGalleryDesc: json['search_gallery_desc'] as bool,
    searchToreenFilenames: json['search_toreen_filenames'] as bool,
    onlyShowWhithTorrents: json['only_show_whith_torrents'] as bool,
    searchLowPowerTags: json['search_low_power_tags'] as bool,
    searchDownvotedTags: json['search_downvoted_tags'] as bool,
    searchExpunged: json['search_expunged'] as bool,
    searchWithminRating: json['search_withmin_rating'] as bool,
    minRating: json['min_rating'] as int,
    searchBetweenpage: json['search_betweenpage'] as bool,
    startPage: json['start_page'] as String,
    endPage: json['end_page'] as String,
    disableDFLanguage: json['disable_d_f_language'] as bool,
    disableDFUploader: json['disable_d_f_uploader'] as bool,
    disableDFTags: json['disable_d_f_tags'] as bool,
    favSearchName: json['fav_search_name'] as bool,
    favSearchTags: json['fav_search_tags'] as bool,
    favSearchNote: json['fav_search_note'] as bool
  );
  
  Map<String, dynamic> toJson() => {
    'search_gallery_name': searchGalleryName,
    'search_gallery_tags': searchGalleryTags,
    'search_gallery_desc': searchGalleryDesc,
    'search_toreen_filenames': searchToreenFilenames,
    'only_show_whith_torrents': onlyShowWhithTorrents,
    'search_low_power_tags': searchLowPowerTags,
    'search_downvoted_tags': searchDownvotedTags,
    'search_expunged': searchExpunged,
    'search_withmin_rating': searchWithminRating,
    'min_rating': minRating,
    'search_betweenpage': searchBetweenpage,
    'start_page': startPage,
    'end_page': endPage,
    'disable_d_f_language': disableDFLanguage,
    'disable_d_f_uploader': disableDFUploader,
    'disable_d_f_tags': disableDFTags,
    'fav_search_name': favSearchName,
    'fav_search_tags': favSearchTags,
    'fav_search_note': favSearchNote
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
