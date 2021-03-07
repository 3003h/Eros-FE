import 'package:flutter/foundation.dart';


@immutable
class EhConfig {
  
  const EhConfig({
    required this.jpnTitle,
    this.tagTranslat,
    this.tagTranslatVer,
    required this.favoritesOrder,
    this.siteEx,
    this.galleryImgBlur,
    this.favPicker,
    this.favLongTap,
    this.lastFavcat,
    this.lastShowFavcat,
    this.lastShowFavTitle,
    required this.listMode,
    this.safeMode,
    required this.catFilter,
    required this.maxHistory,
    this.searchBarComp,
    this.pureDarkTheme,
    required this.viewModel,
    this.clipboardLink,
    this.commentTrans,
    this.autoLockTimeOut,
    this.showPageInterval,
    this.orientation,
  });

  final bool jpnTitle;
  final bool? tagTranslat;
  final String? tagTranslatVer;
  final String favoritesOrder;
  final bool? siteEx;
  final bool? galleryImgBlur;
  final bool? favPicker;
  final bool? favLongTap;
  final String? lastFavcat;
  final String? lastShowFavcat;
  final String? lastShowFavTitle;
  final String listMode;
  final bool? safeMode;
  final int catFilter;
  final int maxHistory;
  final bool? searchBarComp;
  final bool? pureDarkTheme;
  final String viewModel;
  final bool? clipboardLink;
  final bool? commentTrans;
  final int? autoLockTimeOut;
  final bool? showPageInterval;
  final String? orientation;

  factory EhConfig.fromJson(Map<String,dynamic> json) => EhConfig(
    jpnTitle: json['jpn_title'] as bool,
    tagTranslat: json['tag_translat'] != null ? json['tag_translat'] as bool : null,
    tagTranslatVer: json['tag_translat_ver'] != null ? json['tag_translat_ver'] as String : null,
    favoritesOrder: json['favorites_order'] as String,
    siteEx: json['site_ex'] != null ? json['site_ex'] as bool : null,
    galleryImgBlur: json['gallery_img_blur'] != null ? json['gallery_img_blur'] as bool : null,
    favPicker: json['fav_picker'] != null ? json['fav_picker'] as bool : null,
    favLongTap: json['fav_long_tap'] != null ? json['fav_long_tap'] as bool : null,
    lastFavcat: json['last_favcat'] != null ? json['last_favcat'] as String : null,
    lastShowFavcat: json['last_show_favcat'] != null ? json['last_show_favcat'] as String : null,
    lastShowFavTitle: json['last_show_fav_title'] != null ? json['last_show_fav_title'] as String : null,
    listMode: json['list_mode'] as String,
    safeMode: json['safe_mode'] != null ? json['safe_mode'] as bool : null,
    catFilter: json['cat_filter'] as int,
    maxHistory: json['max_history'] as int,
    searchBarComp: json['search_bar_comp'] != null ? json['search_bar_comp'] as bool : null,
    pureDarkTheme: json['pure_dark_theme'] != null ? json['pure_dark_theme'] as bool : null,
    viewModel: json['view_model'] as String,
    clipboardLink: json['clipboard_link'] != null ? json['clipboard_link'] as bool : null,
    commentTrans: json['comment_trans'] != null ? json['comment_trans'] as bool : null,
    autoLockTimeOut: json['auto_lock_time_out'] != null ? json['auto_lock_time_out'] as int : null,
    showPageInterval: json['show_page_interval'] != null ? json['show_page_interval'] as bool : null,
    orientation: json['orientation'] != null ? json['orientation'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'jpn_title': jpnTitle,
    'tag_translat': tagTranslat,
    'tag_translat_ver': tagTranslatVer,
    'favorites_order': favoritesOrder,
    'site_ex': siteEx,
    'gallery_img_blur': galleryImgBlur,
    'fav_picker': favPicker,
    'fav_long_tap': favLongTap,
    'last_favcat': lastFavcat,
    'last_show_favcat': lastShowFavcat,
    'last_show_fav_title': lastShowFavTitle,
    'list_mode': listMode,
    'safe_mode': safeMode,
    'cat_filter': catFilter,
    'max_history': maxHistory,
    'search_bar_comp': searchBarComp,
    'pure_dark_theme': pureDarkTheme,
    'view_model': viewModel,
    'clipboard_link': clipboardLink,
    'comment_trans': commentTrans,
    'auto_lock_time_out': autoLockTimeOut,
    'show_page_interval': showPageInterval,
    'orientation': orientation
  };

  EhConfig clone() => EhConfig(
    jpnTitle: jpnTitle,
    tagTranslat: tagTranslat,
    tagTranslatVer: tagTranslatVer,
    favoritesOrder: favoritesOrder,
    siteEx: siteEx,
    galleryImgBlur: galleryImgBlur,
    favPicker: favPicker,
    favLongTap: favLongTap,
    lastFavcat: lastFavcat,
    lastShowFavcat: lastShowFavcat,
    lastShowFavTitle: lastShowFavTitle,
    listMode: listMode,
    safeMode: safeMode,
    catFilter: catFilter,
    maxHistory: maxHistory,
    searchBarComp: searchBarComp,
    pureDarkTheme: pureDarkTheme,
    viewModel: viewModel,
    clipboardLink: clipboardLink,
    commentTrans: commentTrans,
    autoLockTimeOut: autoLockTimeOut,
    showPageInterval: showPageInterval,
    orientation: orientation
  );

    
  EhConfig copyWith({
    bool? jpnTitle,
    bool? tagTranslat,
    String? tagTranslatVer,
    String? favoritesOrder,
    bool? siteEx,
    bool? galleryImgBlur,
    bool? favPicker,
    bool? favLongTap,
    String? lastFavcat,
    String? lastShowFavcat,
    String? lastShowFavTitle,
    String? listMode,
    bool? safeMode,
    int? catFilter,
    int? maxHistory,
    bool? searchBarComp,
    bool? pureDarkTheme,
    String? viewModel,
    bool? clipboardLink,
    bool? commentTrans,
    int? autoLockTimeOut,
    bool? showPageInterval,
    String? orientation
  }) => EhConfig(
    jpnTitle: jpnTitle ?? this.jpnTitle,
    tagTranslat: tagTranslat ?? this.tagTranslat,
    tagTranslatVer: tagTranslatVer ?? this.tagTranslatVer,
    favoritesOrder: favoritesOrder ?? this.favoritesOrder,
    siteEx: siteEx ?? this.siteEx,
    galleryImgBlur: galleryImgBlur ?? this.galleryImgBlur,
    favPicker: favPicker ?? this.favPicker,
    favLongTap: favLongTap ?? this.favLongTap,
    lastFavcat: lastFavcat ?? this.lastFavcat,
    lastShowFavcat: lastShowFavcat ?? this.lastShowFavcat,
    lastShowFavTitle: lastShowFavTitle ?? this.lastShowFavTitle,
    listMode: listMode ?? this.listMode,
    safeMode: safeMode ?? this.safeMode,
    catFilter: catFilter ?? this.catFilter,
    maxHistory: maxHistory ?? this.maxHistory,
    searchBarComp: searchBarComp ?? this.searchBarComp,
    pureDarkTheme: pureDarkTheme ?? this.pureDarkTheme,
    viewModel: viewModel ?? this.viewModel,
    clipboardLink: clipboardLink ?? this.clipboardLink,
    commentTrans: commentTrans ?? this.commentTrans,
    autoLockTimeOut: autoLockTimeOut ?? this.autoLockTimeOut,
    showPageInterval: showPageInterval ?? this.showPageInterval,
    orientation: orientation ?? this.orientation,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhConfig && jpnTitle == other.jpnTitle && tagTranslat == other.tagTranslat && tagTranslatVer == other.tagTranslatVer && favoritesOrder == other.favoritesOrder && siteEx == other.siteEx && galleryImgBlur == other.galleryImgBlur && favPicker == other.favPicker && favLongTap == other.favLongTap && lastFavcat == other.lastFavcat && lastShowFavcat == other.lastShowFavcat && lastShowFavTitle == other.lastShowFavTitle && listMode == other.listMode && safeMode == other.safeMode && catFilter == other.catFilter && maxHistory == other.maxHistory && searchBarComp == other.searchBarComp && pureDarkTheme == other.pureDarkTheme && viewModel == other.viewModel && clipboardLink == other.clipboardLink && commentTrans == other.commentTrans && autoLockTimeOut == other.autoLockTimeOut && showPageInterval == other.showPageInterval && orientation == other.orientation;

  @override
  int get hashCode => jpnTitle.hashCode ^ tagTranslat.hashCode ^ tagTranslatVer.hashCode ^ favoritesOrder.hashCode ^ siteEx.hashCode ^ galleryImgBlur.hashCode ^ favPicker.hashCode ^ favLongTap.hashCode ^ lastFavcat.hashCode ^ lastShowFavcat.hashCode ^ lastShowFavTitle.hashCode ^ listMode.hashCode ^ safeMode.hashCode ^ catFilter.hashCode ^ maxHistory.hashCode ^ searchBarComp.hashCode ^ pureDarkTheme.hashCode ^ viewModel.hashCode ^ clipboardLink.hashCode ^ commentTrans.hashCode ^ autoLockTimeOut.hashCode ^ showPageInterval.hashCode ^ orientation.hashCode;
}
