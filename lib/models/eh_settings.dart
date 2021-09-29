import 'package:flutter/foundation.dart';


@immutable
class EhSettings {
  
  const EhSettings({
    this.loadImageThroughHAtH,
    this.loadBrowsingCountry,
    this.imageSize,
    this.imageSizeHorizontal,
    this.imageSizeVertical,
    this.galleryNameDisplay,
    this.archiverSettings,
    this.frontPageSettings,
    this.defaultCategories,
    this.favorites,
    this.sortOrderFavorites,
    this.ratings,
    this.tagNamespaces,
    this.tagFilteringThreshold,
    this.tagWatchingThreshold,
    this.excludedLanguages,
    this.excludedUploaders,
    this.searchResultCount,
    this.mouseOverThumbnails,
    this.thumbnailSize,
    this.thumbnailRows,
    this.thumbnailScaling,
    this.viewportOverride,
    this.sortOrderComments,
    this.showCommentVotes,
    this.sortOrderTags,
    this.showGalleryPageNumbers,
    this.hentaiAtHomeLocalNetworkHost,
    this.originalImages,
    this.alwaysUseMpv,
    this.mpvStyle,
    this.mpvThumbnailPane,
  });

  final String? loadImageThroughHAtH;
  final String? loadBrowsingCountry;
  final String? imageSize;
  final String? imageSizeHorizontal;
  final String? imageSizeVertical;
  final String? galleryNameDisplay;
  final String? archiverSettings;
  final String? frontPageSettings;
  final String? defaultCategories;
  final List<String>? favorites;
  final String? sortOrderFavorites;
  final String? ratings;
  final String? tagNamespaces;
  final String? tagFilteringThreshold;
  final String? tagWatchingThreshold;
  final String? excludedLanguages;
  final String? excludedUploaders;
  final String? searchResultCount;
  final String? mouseOverThumbnails;
  final String? thumbnailSize;
  final String? thumbnailRows;
  final String? thumbnailScaling;
  final String? viewportOverride;
  final String? sortOrderComments;
  final String? showCommentVotes;
  final String? sortOrderTags;
  final String? showGalleryPageNumbers;
  final String? hentaiAtHomeLocalNetworkHost;
  final String? originalImages;
  final String? alwaysUseMpv;
  final String? mpvStyle;
  final String? mpvThumbnailPane;

  factory EhSettings.fromJson(Map<String,dynamic> json) => EhSettings(
    loadImageThroughHAtH: json['load_image_through_hAtH'] != null ? json['load_image_through_hAtH'] as String : null,
    loadBrowsingCountry: json['load_browsing_country'] != null ? json['load_browsing_country'] as String : null,
    imageSize: json['image_size'] != null ? json['image_size'] as String : null,
    imageSizeHorizontal: json['image_size_horizontal'] != null ? json['image_size_horizontal'] as String : null,
    imageSizeVertical: json['image_size_vertical'] != null ? json['image_size_vertical'] as String : null,
    galleryNameDisplay: json['gallery_name_display'] != null ? json['gallery_name_display'] as String : null,
    archiverSettings: json['archiver_settings'] != null ? json['archiver_settings'] as String : null,
    frontPageSettings: json['front_page_settings'] != null ? json['front_page_settings'] as String : null,
    defaultCategories: json['default_categories'] != null ? json['default_categories'] as String : null,
    favorites: json['favorites'] != null ? (json['favorites'] as List? ?? []).map((e) => e as String).toList() : null,
    sortOrderFavorites: json['sort_order_favorites'] != null ? json['sort_order_favorites'] as String : null,
    ratings: json['ratings'] != null ? json['ratings'] as String : null,
    tagNamespaces: json['tag_namespaces'] != null ? json['tag_namespaces'] as String : null,
    tagFilteringThreshold: json['tag_filtering_threshold'] != null ? json['tag_filtering_threshold'] as String : null,
    tagWatchingThreshold: json['tag_watching_threshold'] != null ? json['tag_watching_threshold'] as String : null,
    excludedLanguages: json['excluded_languages'] != null ? json['excluded_languages'] as String : null,
    excludedUploaders: json['excluded_uploaders'] != null ? json['excluded_uploaders'] as String : null,
    searchResultCount: json['search_result_count'] != null ? json['search_result_count'] as String : null,
    mouseOverThumbnails: json['mouse-over_thumbnails'] != null ? json['mouse-over_thumbnails'] as String : null,
    thumbnailSize: json['thumbnail_size'] != null ? json['thumbnail_size'] as String : null,
    thumbnailRows: json['thumbnail_rows'] != null ? json['thumbnail_rows'] as String : null,
    thumbnailScaling: json['thumbnail_Scaling'] != null ? json['thumbnail_Scaling'] as String : null,
    viewportOverride: json['viewport_override'] != null ? json['viewport_override'] as String : null,
    sortOrderComments: json['sort_order_comments'] != null ? json['sort_order_comments'] as String : null,
    showCommentVotes: json['show_comment_votes'] != null ? json['show_comment_votes'] as String : null,
    sortOrderTags: json['sort_order_tags'] != null ? json['sort_order_tags'] as String : null,
    showGalleryPageNumbers: json['show_gallery_page_numbers'] != null ? json['show_gallery_page_numbers'] as String : null,
    hentaiAtHomeLocalNetworkHost: json['hentaiAtHome_local_network_host'] != null ? json['hentaiAtHome_local_network_host'] as String : null,
    originalImages: json['original_images'] != null ? json['original_images'] as String : null,
    alwaysUseMpv: json['always_use_mpv'] != null ? json['always_use_mpv'] as String : null,
    mpvStyle: json['mpv_style'] != null ? json['mpv_style'] as String : null,
    mpvThumbnailPane: json['mpv_thumbnail_pane'] != null ? json['mpv_thumbnail_pane'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'load_image_through_hAtH': loadImageThroughHAtH,
    'load_browsing_country': loadBrowsingCountry,
    'image_size': imageSize,
    'image_size_horizontal': imageSizeHorizontal,
    'image_size_vertical': imageSizeVertical,
    'gallery_name_display': galleryNameDisplay,
    'archiver_settings': archiverSettings,
    'front_page_settings': frontPageSettings,
    'default_categories': defaultCategories,
    'favorites': favorites?.map((e) => e.toString()).toList(),
    'sort_order_favorites': sortOrderFavorites,
    'ratings': ratings,
    'tag_namespaces': tagNamespaces,
    'tag_filtering_threshold': tagFilteringThreshold,
    'tag_watching_threshold': tagWatchingThreshold,
    'excluded_languages': excludedLanguages,
    'excluded_uploaders': excludedUploaders,
    'search_result_count': searchResultCount,
    'mouse-over_thumbnails': mouseOverThumbnails,
    'thumbnail_size': thumbnailSize,
    'thumbnail_rows': thumbnailRows,
    'thumbnail_Scaling': thumbnailScaling,
    'viewport_override': viewportOverride,
    'sort_order_comments': sortOrderComments,
    'show_comment_votes': showCommentVotes,
    'sort_order_tags': sortOrderTags,
    'show_gallery_page_numbers': showGalleryPageNumbers,
    'hentaiAtHome_local_network_host': hentaiAtHomeLocalNetworkHost,
    'original_images': originalImages,
    'always_use_mpv': alwaysUseMpv,
    'mpv_style': mpvStyle,
    'mpv_thumbnail_pane': mpvThumbnailPane
  };

  EhSettings clone() => EhSettings(
    loadImageThroughHAtH: loadImageThroughHAtH,
    loadBrowsingCountry: loadBrowsingCountry,
    imageSize: imageSize,
    imageSizeHorizontal: imageSizeHorizontal,
    imageSizeVertical: imageSizeVertical,
    galleryNameDisplay: galleryNameDisplay,
    archiverSettings: archiverSettings,
    frontPageSettings: frontPageSettings,
    defaultCategories: defaultCategories,
    favorites: favorites?.toList(),
    sortOrderFavorites: sortOrderFavorites,
    ratings: ratings,
    tagNamespaces: tagNamespaces,
    tagFilteringThreshold: tagFilteringThreshold,
    tagWatchingThreshold: tagWatchingThreshold,
    excludedLanguages: excludedLanguages,
    excludedUploaders: excludedUploaders,
    searchResultCount: searchResultCount,
    mouseOverThumbnails: mouseOverThumbnails,
    thumbnailSize: thumbnailSize,
    thumbnailRows: thumbnailRows,
    thumbnailScaling: thumbnailScaling,
    viewportOverride: viewportOverride,
    sortOrderComments: sortOrderComments,
    showCommentVotes: showCommentVotes,
    sortOrderTags: sortOrderTags,
    showGalleryPageNumbers: showGalleryPageNumbers,
    hentaiAtHomeLocalNetworkHost: hentaiAtHomeLocalNetworkHost,
    originalImages: originalImages,
    alwaysUseMpv: alwaysUseMpv,
    mpvStyle: mpvStyle,
    mpvThumbnailPane: mpvThumbnailPane
  );

    
  EhSettings copyWith({
    String? loadImageThroughHAtH,
    String? loadBrowsingCountry,
    String? imageSize,
    String? imageSizeHorizontal,
    String? imageSizeVertical,
    String? galleryNameDisplay,
    String? archiverSettings,
    String? frontPageSettings,
    String? defaultCategories,
    List<String>? favorites,
    String? sortOrderFavorites,
    String? ratings,
    String? tagNamespaces,
    String? tagFilteringThreshold,
    String? tagWatchingThreshold,
    String? excludedLanguages,
    String? excludedUploaders,
    String? searchResultCount,
    String? mouseOverThumbnails,
    String? thumbnailSize,
    String? thumbnailRows,
    String? thumbnailScaling,
    String? viewportOverride,
    String? sortOrderComments,
    String? showCommentVotes,
    String? sortOrderTags,
    String? showGalleryPageNumbers,
    String? hentaiAtHomeLocalNetworkHost,
    String? originalImages,
    String? alwaysUseMpv,
    String? mpvStyle,
    String? mpvThumbnailPane
  }) => EhSettings(
    loadImageThroughHAtH: loadImageThroughHAtH ?? this.loadImageThroughHAtH,
    loadBrowsingCountry: loadBrowsingCountry ?? this.loadBrowsingCountry,
    imageSize: imageSize ?? this.imageSize,
    imageSizeHorizontal: imageSizeHorizontal ?? this.imageSizeHorizontal,
    imageSizeVertical: imageSizeVertical ?? this.imageSizeVertical,
    galleryNameDisplay: galleryNameDisplay ?? this.galleryNameDisplay,
    archiverSettings: archiverSettings ?? this.archiverSettings,
    frontPageSettings: frontPageSettings ?? this.frontPageSettings,
    defaultCategories: defaultCategories ?? this.defaultCategories,
    favorites: favorites ?? this.favorites,
    sortOrderFavorites: sortOrderFavorites ?? this.sortOrderFavorites,
    ratings: ratings ?? this.ratings,
    tagNamespaces: tagNamespaces ?? this.tagNamespaces,
    tagFilteringThreshold: tagFilteringThreshold ?? this.tagFilteringThreshold,
    tagWatchingThreshold: tagWatchingThreshold ?? this.tagWatchingThreshold,
    excludedLanguages: excludedLanguages ?? this.excludedLanguages,
    excludedUploaders: excludedUploaders ?? this.excludedUploaders,
    searchResultCount: searchResultCount ?? this.searchResultCount,
    mouseOverThumbnails: mouseOverThumbnails ?? this.mouseOverThumbnails,
    thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    thumbnailRows: thumbnailRows ?? this.thumbnailRows,
    thumbnailScaling: thumbnailScaling ?? this.thumbnailScaling,
    viewportOverride: viewportOverride ?? this.viewportOverride,
    sortOrderComments: sortOrderComments ?? this.sortOrderComments,
    showCommentVotes: showCommentVotes ?? this.showCommentVotes,
    sortOrderTags: sortOrderTags ?? this.sortOrderTags,
    showGalleryPageNumbers: showGalleryPageNumbers ?? this.showGalleryPageNumbers,
    hentaiAtHomeLocalNetworkHost: hentaiAtHomeLocalNetworkHost ?? this.hentaiAtHomeLocalNetworkHost,
    originalImages: originalImages ?? this.originalImages,
    alwaysUseMpv: alwaysUseMpv ?? this.alwaysUseMpv,
    mpvStyle: mpvStyle ?? this.mpvStyle,
    mpvThumbnailPane: mpvThumbnailPane ?? this.mpvThumbnailPane,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhSettings && loadImageThroughHAtH == other.loadImageThroughHAtH && loadBrowsingCountry == other.loadBrowsingCountry && imageSize == other.imageSize && imageSizeHorizontal == other.imageSizeHorizontal && imageSizeVertical == other.imageSizeVertical && galleryNameDisplay == other.galleryNameDisplay && archiverSettings == other.archiverSettings && frontPageSettings == other.frontPageSettings && defaultCategories == other.defaultCategories && favorites == other.favorites && sortOrderFavorites == other.sortOrderFavorites && ratings == other.ratings && tagNamespaces == other.tagNamespaces && tagFilteringThreshold == other.tagFilteringThreshold && tagWatchingThreshold == other.tagWatchingThreshold && excludedLanguages == other.excludedLanguages && excludedUploaders == other.excludedUploaders && searchResultCount == other.searchResultCount && mouseOverThumbnails == other.mouseOverThumbnails && thumbnailSize == other.thumbnailSize && thumbnailRows == other.thumbnailRows && thumbnailScaling == other.thumbnailScaling && viewportOverride == other.viewportOverride && sortOrderComments == other.sortOrderComments && showCommentVotes == other.showCommentVotes && sortOrderTags == other.sortOrderTags && showGalleryPageNumbers == other.showGalleryPageNumbers && hentaiAtHomeLocalNetworkHost == other.hentaiAtHomeLocalNetworkHost && originalImages == other.originalImages && alwaysUseMpv == other.alwaysUseMpv && mpvStyle == other.mpvStyle && mpvThumbnailPane == other.mpvThumbnailPane;

  @override
  int get hashCode => loadImageThroughHAtH.hashCode ^ loadBrowsingCountry.hashCode ^ imageSize.hashCode ^ imageSizeHorizontal.hashCode ^ imageSizeVertical.hashCode ^ galleryNameDisplay.hashCode ^ archiverSettings.hashCode ^ frontPageSettings.hashCode ^ defaultCategories.hashCode ^ favorites.hashCode ^ sortOrderFavorites.hashCode ^ ratings.hashCode ^ tagNamespaces.hashCode ^ tagFilteringThreshold.hashCode ^ tagWatchingThreshold.hashCode ^ excludedLanguages.hashCode ^ excludedUploaders.hashCode ^ searchResultCount.hashCode ^ mouseOverThumbnails.hashCode ^ thumbnailSize.hashCode ^ thumbnailRows.hashCode ^ thumbnailScaling.hashCode ^ viewportOverride.hashCode ^ sortOrderComments.hashCode ^ showCommentVotes.hashCode ^ sortOrderTags.hashCode ^ showGalleryPageNumbers.hashCode ^ hentaiAtHomeLocalNetworkHost.hashCode ^ originalImages.hashCode ^ alwaysUseMpv.hashCode ^ mpvStyle.hashCode ^ mpvThumbnailPane.hashCode;
}
