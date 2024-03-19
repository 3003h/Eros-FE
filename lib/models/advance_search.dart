import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    startPage: json['startPage']?.toString(),
    endPage: json['endPage']?.toString(),
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
    Optional<bool?>? requireGalleryTorrent,
    Optional<bool?>? browseExpungedGalleries,
    Optional<bool?>? searchWithMinRating,
    Optional<int?>? minRating,
    Optional<bool?>? searchBetweenPage,
    Optional<String?>? startPage,
    Optional<String?>? endPage,
    Optional<bool?>? disableCustomFilterLanguage,
    Optional<bool?>? disableCustomFilterUploader,
    Optional<bool?>? disableCustomFilterTags
  }) => AdvanceSearch(
    requireGalleryTorrent: checkOptional(requireGalleryTorrent, () => this.requireGalleryTorrent),
    browseExpungedGalleries: checkOptional(browseExpungedGalleries, () => this.browseExpungedGalleries),
    searchWithMinRating: checkOptional(searchWithMinRating, () => this.searchWithMinRating),
    minRating: checkOptional(minRating, () => this.minRating),
    searchBetweenPage: checkOptional(searchBetweenPage, () => this.searchBetweenPage),
    startPage: checkOptional(startPage, () => this.startPage),
    endPage: checkOptional(endPage, () => this.endPage),
    disableCustomFilterLanguage: checkOptional(disableCustomFilterLanguage, () => this.disableCustomFilterLanguage),
    disableCustomFilterUploader: checkOptional(disableCustomFilterUploader, () => this.disableCustomFilterUploader),
    disableCustomFilterTags: checkOptional(disableCustomFilterTags, () => this.disableCustomFilterTags),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is AdvanceSearch && requireGalleryTorrent == other.requireGalleryTorrent && browseExpungedGalleries == other.browseExpungedGalleries && searchWithMinRating == other.searchWithMinRating && minRating == other.minRating && searchBetweenPage == other.searchBetweenPage && startPage == other.startPage && endPage == other.endPage && disableCustomFilterLanguage == other.disableCustomFilterLanguage && disableCustomFilterUploader == other.disableCustomFilterUploader && disableCustomFilterTags == other.disableCustomFilterTags;

  @override
  int get hashCode => requireGalleryTorrent.hashCode ^ browseExpungedGalleries.hashCode ^ searchWithMinRating.hashCode ^ minRating.hashCode ^ searchBetweenPage.hashCode ^ startPage.hashCode ^ endPage.hashCode ^ disableCustomFilterLanguage.hashCode ^ disableCustomFilterUploader.hashCode ^ disableCustomFilterTags.hashCode;
}
