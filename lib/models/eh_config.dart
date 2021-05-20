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
    this.vibrate,
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
  final bool? vibrate;

  factory EhConfig.fromJson(Map<String,dynamic> json) => EhConfig(
    jpnTitle: json['jpnTitle'] as bool,
    tagTranslat: json['tagTranslat'] != null ? json['tagTranslat'] as bool : null,
    tagTranslatVer: json['tagTranslatVer'] != null ? json['tagTranslatVer'] as String : null,
    favoritesOrder: json['favoritesOrder'] as String,
    siteEx: json['siteEx'] != null ? json['siteEx'] as bool : null,
    galleryImgBlur: json['galleryImgBlur'] != null ? json['galleryImgBlur'] as bool : null,
    favPicker: json['favPicker'] != null ? json['favPicker'] as bool : null,
    favLongTap: json['favLongTap'] != null ? json['favLongTap'] as bool : null,
    lastFavcat: json['lastFavcat'] != null ? json['lastFavcat'] as String : null,
    lastShowFavcat: json['lastShowFavcat'] != null ? json['lastShowFavcat'] as String : null,
    lastShowFavTitle: json['lastShowFavTitle'] != null ? json['lastShowFavTitle'] as String : null,
    listMode: json['listMode'] as String,
    safeMode: json['safeMode'] != null ? json['safeMode'] as bool : null,
    catFilter: json['catFilter'] as int,
    maxHistory: json['maxHistory'] as int,
    searchBarComp: json['searchBarComp'] != null ? json['searchBarComp'] as bool : null,
    pureDarkTheme: json['pureDarkTheme'] != null ? json['pureDarkTheme'] as bool : null,
    viewModel: json['viewModel'] as String,
    clipboardLink: json['clipboardLink'] != null ? json['clipboardLink'] as bool : null,
    commentTrans: json['commentTrans'] != null ? json['commentTrans'] as bool : null,
    autoLockTimeOut: json['autoLockTimeOut'] != null ? json['autoLockTimeOut'] as int : null,
    showPageInterval: json['showPageInterval'] != null ? json['showPageInterval'] as bool : null,
    orientation: json['orientation'] != null ? json['orientation'] as String : null,
    vibrate: json['vibrate'] != null ? json['vibrate'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'jpnTitle': jpnTitle,
    'tagTranslat': tagTranslat,
    'tagTranslatVer': tagTranslatVer,
    'favoritesOrder': favoritesOrder,
    'siteEx': siteEx,
    'galleryImgBlur': galleryImgBlur,
    'favPicker': favPicker,
    'favLongTap': favLongTap,
    'lastFavcat': lastFavcat,
    'lastShowFavcat': lastShowFavcat,
    'lastShowFavTitle': lastShowFavTitle,
    'listMode': listMode,
    'safeMode': safeMode,
    'catFilter': catFilter,
    'maxHistory': maxHistory,
    'searchBarComp': searchBarComp,
    'pureDarkTheme': pureDarkTheme,
    'viewModel': viewModel,
    'clipboardLink': clipboardLink,
    'commentTrans': commentTrans,
    'autoLockTimeOut': autoLockTimeOut,
    'showPageInterval': showPageInterval,
    'orientation': orientation,
    'vibrate': vibrate
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
    orientation: orientation,
    vibrate: vibrate
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
    String? orientation,
    bool? vibrate
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
    vibrate: vibrate ?? this.vibrate,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhConfig && jpnTitle == other.jpnTitle && tagTranslat == other.tagTranslat && tagTranslatVer == other.tagTranslatVer && favoritesOrder == other.favoritesOrder && siteEx == other.siteEx && galleryImgBlur == other.galleryImgBlur && favPicker == other.favPicker && favLongTap == other.favLongTap && lastFavcat == other.lastFavcat && lastShowFavcat == other.lastShowFavcat && lastShowFavTitle == other.lastShowFavTitle && listMode == other.listMode && safeMode == other.safeMode && catFilter == other.catFilter && maxHistory == other.maxHistory && searchBarComp == other.searchBarComp && pureDarkTheme == other.pureDarkTheme && viewModel == other.viewModel && clipboardLink == other.clipboardLink && commentTrans == other.commentTrans && autoLockTimeOut == other.autoLockTimeOut && showPageInterval == other.showPageInterval && orientation == other.orientation && vibrate == other.vibrate;

  @override
  int get hashCode => jpnTitle.hashCode ^ tagTranslat.hashCode ^ tagTranslatVer.hashCode ^ favoritesOrder.hashCode ^ siteEx.hashCode ^ galleryImgBlur.hashCode ^ favPicker.hashCode ^ favLongTap.hashCode ^ lastFavcat.hashCode ^ lastShowFavcat.hashCode ^ lastShowFavTitle.hashCode ^ listMode.hashCode ^ safeMode.hashCode ^ catFilter.hashCode ^ maxHistory.hashCode ^ searchBarComp.hashCode ^ pureDarkTheme.hashCode ^ viewModel.hashCode ^ clipboardLink.hashCode ^ commentTrans.hashCode ^ autoLockTimeOut.hashCode ^ showPageInterval.hashCode ^ orientation.hashCode ^ vibrate.hashCode;
}
