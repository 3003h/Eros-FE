import 'package:flutter/foundation.dart';


@immutable
class AdvanceSearch {
  
  const AdvanceSearch({
    this.requireGalleryTorrent,
    this.browseExpungedGalleries,
    this.searchWithMinRating,
    this.minRating,
    this.searchBetweenPage,
    this.startPage,
    this.endPage,
    this.disableCustomFilterLanguage,
    this.disableCustomFilterUploader,
    this.disableCustomFilterTags,
  });

  final bool? requireGalleryTorrent;
  final bool? browseExpungedGalleries;
  final bool? searchWithMinRating;
  final int? minRating;
  final bool? searchBetweenPage;
  final String? startPage;
  final String? endPage;
  final bool? disableCustomFilterLanguage;
  final bool? disableCustomFilterUploader;
  final bool? disableCustomFilterTags;

  factory AdvanceSearch.fromJson(Map<String,dynamic> json) => AdvanceSearch(
    requireGalleryTorrent: json['requireGalleryTorrent'] != null ? json['requireGalleryTorrent'] as bool : null,
    browseExpungedGalleries: json['browseExpungedGalleries'] != null ? json['browseExpungedGalleries'] as bool : null,
    searchWithMinRating: json['searchWithMinRating'] != null ? json['searchWithMinRating'] as bool : null,
    minRating: json['minRating'] != null ? json['minRating'] as int : null,
    searchBetweenPage: json['searchBetweenPage'] != null ? json['searchBetweenPage'] as bool : null,
    startPage: json['startPage'] != null ? json['startPage'] as String : null,
    endPage: json['endPage'] != null ? json['endPage'] as String : null,
    disableCustomFilterLanguage: json['disableCustomFilterLanguage'] != null ? json['disableCustomFilterLanguage'] as bool : null,
    disableCustomFilterUploader: json['disableCustomFilterUploader'] != null ? json['disableCustomFilterUploader'] as bool : null,
    disableCustomFilterTags: json['disableCustomFilterTags'] != null ? json['disableCustomFilterTags'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'requireGalleryTorrent': requireGalleryTorrent,
    'browseExpungedGalleries': browseExpungedGalleries,
    'searchWithMinRating': searchWithMinRating,
    'minRating': minRating,
    'searchBetweenPage': searchBetweenPage,
    'startPage': startPage,
    'endPage': endPage,
    'disableCustomFilterLanguage': disableCustomFilterLanguage,
    'disableCustomFilterUploader': disableCustomFilterUploader,
    'disableCustomFilterTags': disableCustomFilterTags
  };

  AdvanceSearch clone() => AdvanceSearch(
    requireGalleryTorrent: requireGalleryTorrent,
    browseExpungedGalleries: browseExpungedGalleries,
    searchWithMinRating: searchWithMinRating,
    minRating: minRating,
    searchBetweenPage: searchBetweenPage,
    startPage: startPage,
    endPage: endPage,
    disableCustomFilterLanguage: disableCustomFilterLanguage,
    disableCustomFilterUploader: disableCustomFilterUploader,
    disableCustomFilterTags: disableCustomFilterTags
  );

    
  AdvanceSearch copyWith({
    bool? requireGalleryTorrent,
    bool? browseExpungedGalleries,
    bool? searchWithMinRating,
    int? minRating,
    bool? searchBetweenPage,
    String? startPage,
    String? endPage,
    bool? disableCustomFilterLanguage,
    bool? disableCustomFilterUploader,
    bool? disableCustomFilterTags
  }) => AdvanceSearch(
    requireGalleryTorrent: requireGalleryTorrent ?? this.requireGalleryTorrent,
    browseExpungedGalleries: browseExpungedGalleries ?? this.browseExpungedGalleries,
    searchWithMinRating: searchWithMinRating ?? this.searchWithMinRating,
    minRating: minRating ?? this.minRating,
    searchBetweenPage: searchBetweenPage ?? this.searchBetweenPage,
    startPage: startPage ?? this.startPage,
    endPage: endPage ?? this.endPage,
    disableCustomFilterLanguage: disableCustomFilterLanguage ?? this.disableCustomFilterLanguage,
    disableCustomFilterUploader: disableCustomFilterUploader ?? this.disableCustomFilterUploader,
    disableCustomFilterTags: disableCustomFilterTags ?? this.disableCustomFilterTags,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is AdvanceSearch && requireGalleryTorrent == other.requireGalleryTorrent && browseExpungedGalleries == other.browseExpungedGalleries && searchWithMinRating == other.searchWithMinRating && minRating == other.minRating && searchBetweenPage == other.searchBetweenPage && startPage == other.startPage && endPage == other.endPage && disableCustomFilterLanguage == other.disableCustomFilterLanguage && disableCustomFilterUploader == other.disableCustomFilterUploader && disableCustomFilterTags == other.disableCustomFilterTags;

  @override
  int get hashCode => requireGalleryTorrent.hashCode ^ browseExpungedGalleries.hashCode ^ searchWithMinRating.hashCode ^ minRating.hashCode ^ searchBetweenPage.hashCode ^ startPage.hashCode ^ endPage.hashCode ^ disableCustomFilterLanguage.hashCode ^ disableCustomFilterUploader.hashCode ^ disableCustomFilterTags.hashCode;
}
