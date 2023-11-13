import 'package:flutter/foundation.dart';


@immutable
class EhConfig {
  
  const EhConfig({
    this.jpnTitleInGalleryPage,
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
    this.tagIntroImgLv,
    this.debugMode,
    this.debugCount,
    this.autoRead,
    this.turnPageInv,
    this.toplist,
    this.tabletLayout,
    this.tabletLayoutValue,
    this.enableTagTranslateCDN,
    this.autoSelectProfile,
    this.turnPageAnimations,
    this.selectProfile,
    this.linkRedirect,
    this.viewColumnMode,
    this.fixedHeightOfListItems,
    this.tagTranslateDataUpdateMode,
    this.showCommentAvatar,
    this.avatarType,
    this.boringAvatarsType,
    this.textAvatarsType,
    this.avatarBorderRadiusType,
    this.enablePHashCheck,
    this.enableQRCodeCheck,
    this.viewFullscreen,
    this.blurringOfCoverBackground,
    this.listViewTagLimit,
    this.redirectThumbLink,
    this.volumnTurnPage,
    this.proxyType,
    this.proxyHost,
    this.proxyPort,
    this.proxyUsername,
    this.proxyPassword,
    this.webDAVMaxConnections,
    this.hideTopBarOnScroll,
    this.readViewCompatibleMode,
    this.translateSearchHistory,
    this.nativeHttpClientAdapter,
    this.showComments,
    this.showOnlyUploaderComment,
    this.showGalleryTags,
    this.hideGalleryThumbnails,
    this.horizontalThumbnails,
    this.pHashThreshold,
  });

  final bool? jpnTitleInGalleryPage;
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
  final String? tagIntroImgLv;
  final bool? debugMode;
  final int? debugCount;
  final bool? autoRead;
  final int? turnPageInv;
  final String? toplist;
  final bool? tabletLayout;
  final String? tabletLayoutValue;
  final bool? enableTagTranslateCDN;
  final bool? autoSelectProfile;
  final bool? turnPageAnimations;
  final String? selectProfile;
  final bool? linkRedirect;
  final String? viewColumnMode;
  final bool? fixedHeightOfListItems;
  final String? tagTranslateDataUpdateMode;
  final bool? showCommentAvatar;
  final String? avatarType;
  final String? boringAvatarsType;
  final String? textAvatarsType;
  final String? avatarBorderRadiusType;
  final bool? enablePHashCheck;
  final bool? enableQRCodeCheck;
  final bool? viewFullscreen;
  final bool? blurringOfCoverBackground;
  final int? listViewTagLimit;
  final bool? redirectThumbLink;
  final bool? volumnTurnPage;
  final String? proxyType;
  final String? proxyHost;
  final int? proxyPort;
  final String? proxyUsername;
  final String? proxyPassword;
  final int? webDAVMaxConnections;
  final bool? hideTopBarOnScroll;
  final bool? readViewCompatibleMode;
  final bool? translateSearchHistory;
  final bool? nativeHttpClientAdapter;
  final bool? showComments;
  final bool? showOnlyUploaderComment;
  final bool? showGalleryTags;
  final bool? hideGalleryThumbnails;
  final bool? horizontalThumbnails;
  final int? pHashThreshold;

  factory EhConfig.fromJson(Map<String,dynamic> json) => EhConfig(
    jpnTitleInGalleryPage: json['jpnTitleInGalleryPage'] != null ? json['jpnTitleInGalleryPage'] as bool : null,
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
    vibrate: json['vibrate'] != null ? json['vibrate'] as bool : null,
    tagIntroImgLv: json['tagIntroImgLv'] != null ? json['tagIntroImgLv'] as String : null,
    debugMode: json['debugMode'] != null ? json['debugMode'] as bool : null,
    debugCount: json['debugCount'] != null ? json['debugCount'] as int : null,
    autoRead: json['autoRead'] != null ? json['autoRead'] as bool : null,
    turnPageInv: json['turnPageInv'] != null ? json['turnPageInv'] as int : null,
    toplist: json['toplist'] != null ? json['toplist'] as String : null,
    tabletLayout: json['tabletLayout'] != null ? json['tabletLayout'] as bool : null,
    tabletLayoutValue: json['tabletLayoutValue'] != null ? json['tabletLayoutValue'] as String : null,
    enableTagTranslateCDN: json['enableTagTranslateCDN'] != null ? json['enableTagTranslateCDN'] as bool : null,
    autoSelectProfile: json['autoSelectProfile'] != null ? json['autoSelectProfile'] as bool : null,
    turnPageAnimations: json['turnPageAnimations'] != null ? json['turnPageAnimations'] as bool : null,
    selectProfile: json['selectProfile'] != null ? json['selectProfile'] as String : null,
    linkRedirect: json['linkRedirect'] != null ? json['linkRedirect'] as bool : null,
    viewColumnMode: json['viewColumnMode'] != null ? json['viewColumnMode'] as String : null,
    fixedHeightOfListItems: json['fixedHeightOfListItems'] != null ? json['fixedHeightOfListItems'] as bool : null,
    tagTranslateDataUpdateMode: json['tagTranslateDataUpdateMode'] != null ? json['tagTranslateDataUpdateMode'] as String : null,
    showCommentAvatar: json['showCommentAvatar'] != null ? json['showCommentAvatar'] as bool : null,
    avatarType: json['avatarType'] != null ? json['avatarType'] as String : null,
    boringAvatarsType: json['boringAvatarsType'] != null ? json['boringAvatarsType'] as String : null,
    textAvatarsType: json['textAvatarsType'] != null ? json['textAvatarsType'] as String : null,
    avatarBorderRadiusType: json['avatarBorderRadiusType'] != null ? json['avatarBorderRadiusType'] as String : null,
    enablePHashCheck: json['enablePHashCheck'] != null ? json['enablePHashCheck'] as bool : null,
    enableQRCodeCheck: json['enableQRCodeCheck'] != null ? json['enableQRCodeCheck'] as bool : null,
    viewFullscreen: json['viewFullscreen'] != null ? json['viewFullscreen'] as bool : null,
    blurringOfCoverBackground: json['blurringOfCoverBackground'] != null ? json['blurringOfCoverBackground'] as bool : null,
    listViewTagLimit: json['listViewTagLimit'] != null ? json['listViewTagLimit'] as int : null,
    redirectThumbLink: json['redirectThumbLink'] != null ? json['redirectThumbLink'] as bool : null,
    volumnTurnPage: json['volumnTurnPage'] != null ? json['volumnTurnPage'] as bool : null,
    proxyType: json['proxyType'] != null ? json['proxyType'] as String : null,
    proxyHost: json['proxyHost'] != null ? json['proxyHost'] as String : null,
    proxyPort: json['proxyPort'] != null ? json['proxyPort'] as int : null,
    proxyUsername: json['proxyUsername'] != null ? json['proxyUsername'] as String : null,
    proxyPassword: json['proxyPassword'] != null ? json['proxyPassword'] as String : null,
    webDAVMaxConnections: json['webDAVMaxConnections'] != null ? json['webDAVMaxConnections'] as int : null,
    hideTopBarOnScroll: json['hideTopBarOnScroll'] != null ? json['hideTopBarOnScroll'] as bool : null,
    readViewCompatibleMode: json['readViewCompatibleMode'] != null ? json['readViewCompatibleMode'] as bool : null,
    translateSearchHistory: json['translateSearchHistory'] != null ? json['translateSearchHistory'] as bool : null,
    nativeHttpClientAdapter: json['nativeHttpClientAdapter'] != null ? json['nativeHttpClientAdapter'] as bool : null,
    showComments: json['showComments'] != null ? json['showComments'] as bool : null,
    showOnlyUploaderComment: json['showOnlyUploaderComment'] != null ? json['showOnlyUploaderComment'] as bool : null,
    showGalleryTags: json['showGalleryTags'] != null ? json['showGalleryTags'] as bool : null,
    hideGalleryThumbnails: json['hideGalleryThumbnails'] != null ? json['hideGalleryThumbnails'] as bool : null,
    horizontalThumbnails: json['horizontalThumbnails'] != null ? json['horizontalThumbnails'] as bool : null,
    pHashThreshold: json['pHashThreshold'] != null ? json['pHashThreshold'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'jpnTitleInGalleryPage': jpnTitleInGalleryPage,
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
    'vibrate': vibrate,
    'tagIntroImgLv': tagIntroImgLv,
    'debugMode': debugMode,
    'debugCount': debugCount,
    'autoRead': autoRead,
    'turnPageInv': turnPageInv,
    'toplist': toplist,
    'tabletLayout': tabletLayout,
    'tabletLayoutValue': tabletLayoutValue,
    'enableTagTranslateCDN': enableTagTranslateCDN,
    'autoSelectProfile': autoSelectProfile,
    'turnPageAnimations': turnPageAnimations,
    'selectProfile': selectProfile,
    'linkRedirect': linkRedirect,
    'viewColumnMode': viewColumnMode,
    'fixedHeightOfListItems': fixedHeightOfListItems,
    'tagTranslateDataUpdateMode': tagTranslateDataUpdateMode,
    'showCommentAvatar': showCommentAvatar,
    'avatarType': avatarType,
    'boringAvatarsType': boringAvatarsType,
    'textAvatarsType': textAvatarsType,
    'avatarBorderRadiusType': avatarBorderRadiusType,
    'enablePHashCheck': enablePHashCheck,
    'enableQRCodeCheck': enableQRCodeCheck,
    'viewFullscreen': viewFullscreen,
    'blurringOfCoverBackground': blurringOfCoverBackground,
    'listViewTagLimit': listViewTagLimit,
    'redirectThumbLink': redirectThumbLink,
    'volumnTurnPage': volumnTurnPage,
    'proxyType': proxyType,
    'proxyHost': proxyHost,
    'proxyPort': proxyPort,
    'proxyUsername': proxyUsername,
    'proxyPassword': proxyPassword,
    'webDAVMaxConnections': webDAVMaxConnections,
    'hideTopBarOnScroll': hideTopBarOnScroll,
    'readViewCompatibleMode': readViewCompatibleMode,
    'translateSearchHistory': translateSearchHistory,
    'nativeHttpClientAdapter': nativeHttpClientAdapter,
    'showComments': showComments,
    'showOnlyUploaderComment': showOnlyUploaderComment,
    'showGalleryTags': showGalleryTags,
    'hideGalleryThumbnails': hideGalleryThumbnails,
    'horizontalThumbnails': horizontalThumbnails,
    'pHashThreshold': pHashThreshold
  };

  EhConfig clone() => EhConfig(
    jpnTitleInGalleryPage: jpnTitleInGalleryPage,
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
    vibrate: vibrate,
    tagIntroImgLv: tagIntroImgLv,
    debugMode: debugMode,
    debugCount: debugCount,
    autoRead: autoRead,
    turnPageInv: turnPageInv,
    toplist: toplist,
    tabletLayout: tabletLayout,
    tabletLayoutValue: tabletLayoutValue,
    enableTagTranslateCDN: enableTagTranslateCDN,
    autoSelectProfile: autoSelectProfile,
    turnPageAnimations: turnPageAnimations,
    selectProfile: selectProfile,
    linkRedirect: linkRedirect,
    viewColumnMode: viewColumnMode,
    fixedHeightOfListItems: fixedHeightOfListItems,
    tagTranslateDataUpdateMode: tagTranslateDataUpdateMode,
    showCommentAvatar: showCommentAvatar,
    avatarType: avatarType,
    boringAvatarsType: boringAvatarsType,
    textAvatarsType: textAvatarsType,
    avatarBorderRadiusType: avatarBorderRadiusType,
    enablePHashCheck: enablePHashCheck,
    enableQRCodeCheck: enableQRCodeCheck,
    viewFullscreen: viewFullscreen,
    blurringOfCoverBackground: blurringOfCoverBackground,
    listViewTagLimit: listViewTagLimit,
    redirectThumbLink: redirectThumbLink,
    volumnTurnPage: volumnTurnPage,
    proxyType: proxyType,
    proxyHost: proxyHost,
    proxyPort: proxyPort,
    proxyUsername: proxyUsername,
    proxyPassword: proxyPassword,
    webDAVMaxConnections: webDAVMaxConnections,
    hideTopBarOnScroll: hideTopBarOnScroll,
    readViewCompatibleMode: readViewCompatibleMode,
    translateSearchHistory: translateSearchHistory,
    nativeHttpClientAdapter: nativeHttpClientAdapter,
    showComments: showComments,
    showOnlyUploaderComment: showOnlyUploaderComment,
    showGalleryTags: showGalleryTags,
    hideGalleryThumbnails: hideGalleryThumbnails,
    horizontalThumbnails: horizontalThumbnails,
    pHashThreshold: pHashThreshold
  );

    
  EhConfig copyWith({
    bool? jpnTitleInGalleryPage,
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
    bool? vibrate,
    String? tagIntroImgLv,
    bool? debugMode,
    int? debugCount,
    bool? autoRead,
    int? turnPageInv,
    String? toplist,
    bool? tabletLayout,
    String? tabletLayoutValue,
    bool? enableTagTranslateCDN,
    bool? autoSelectProfile,
    bool? turnPageAnimations,
    String? selectProfile,
    bool? linkRedirect,
    String? viewColumnMode,
    bool? fixedHeightOfListItems,
    String? tagTranslateDataUpdateMode,
    bool? showCommentAvatar,
    String? avatarType,
    String? boringAvatarsType,
    String? textAvatarsType,
    String? avatarBorderRadiusType,
    bool? enablePHashCheck,
    bool? enableQRCodeCheck,
    bool? viewFullscreen,
    bool? blurringOfCoverBackground,
    int? listViewTagLimit,
    bool? redirectThumbLink,
    bool? volumnTurnPage,
    String? proxyType,
    String? proxyHost,
    int? proxyPort,
    String? proxyUsername,
    String? proxyPassword,
    int? webDAVMaxConnections,
    bool? hideTopBarOnScroll,
    bool? readViewCompatibleMode,
    bool? translateSearchHistory,
    bool? nativeHttpClientAdapter,
    bool? showComments,
    bool? showOnlyUploaderComment,
    bool? showGalleryTags,
    bool? hideGalleryThumbnails,
    bool? horizontalThumbnails,
    int? pHashThreshold
  }) => EhConfig(
    jpnTitleInGalleryPage: jpnTitleInGalleryPage ?? this.jpnTitleInGalleryPage,
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
    tagIntroImgLv: tagIntroImgLv ?? this.tagIntroImgLv,
    debugMode: debugMode ?? this.debugMode,
    debugCount: debugCount ?? this.debugCount,
    autoRead: autoRead ?? this.autoRead,
    turnPageInv: turnPageInv ?? this.turnPageInv,
    toplist: toplist ?? this.toplist,
    tabletLayout: tabletLayout ?? this.tabletLayout,
    tabletLayoutValue: tabletLayoutValue ?? this.tabletLayoutValue,
    enableTagTranslateCDN: enableTagTranslateCDN ?? this.enableTagTranslateCDN,
    autoSelectProfile: autoSelectProfile ?? this.autoSelectProfile,
    turnPageAnimations: turnPageAnimations ?? this.turnPageAnimations,
    selectProfile: selectProfile ?? this.selectProfile,
    linkRedirect: linkRedirect ?? this.linkRedirect,
    viewColumnMode: viewColumnMode ?? this.viewColumnMode,
    fixedHeightOfListItems: fixedHeightOfListItems ?? this.fixedHeightOfListItems,
    tagTranslateDataUpdateMode: tagTranslateDataUpdateMode ?? this.tagTranslateDataUpdateMode,
    showCommentAvatar: showCommentAvatar ?? this.showCommentAvatar,
    avatarType: avatarType ?? this.avatarType,
    boringAvatarsType: boringAvatarsType ?? this.boringAvatarsType,
    textAvatarsType: textAvatarsType ?? this.textAvatarsType,
    avatarBorderRadiusType: avatarBorderRadiusType ?? this.avatarBorderRadiusType,
    enablePHashCheck: enablePHashCheck ?? this.enablePHashCheck,
    enableQRCodeCheck: enableQRCodeCheck ?? this.enableQRCodeCheck,
    viewFullscreen: viewFullscreen ?? this.viewFullscreen,
    blurringOfCoverBackground: blurringOfCoverBackground ?? this.blurringOfCoverBackground,
    listViewTagLimit: listViewTagLimit ?? this.listViewTagLimit,
    redirectThumbLink: redirectThumbLink ?? this.redirectThumbLink,
    volumnTurnPage: volumnTurnPage ?? this.volumnTurnPage,
    proxyType: proxyType ?? this.proxyType,
    proxyHost: proxyHost ?? this.proxyHost,
    proxyPort: proxyPort ?? this.proxyPort,
    proxyUsername: proxyUsername ?? this.proxyUsername,
    proxyPassword: proxyPassword ?? this.proxyPassword,
    webDAVMaxConnections: webDAVMaxConnections ?? this.webDAVMaxConnections,
    hideTopBarOnScroll: hideTopBarOnScroll ?? this.hideTopBarOnScroll,
    readViewCompatibleMode: readViewCompatibleMode ?? this.readViewCompatibleMode,
    translateSearchHistory: translateSearchHistory ?? this.translateSearchHistory,
    nativeHttpClientAdapter: nativeHttpClientAdapter ?? this.nativeHttpClientAdapter,
    showComments: showComments ?? this.showComments,
    showOnlyUploaderComment: showOnlyUploaderComment ?? this.showOnlyUploaderComment,
    showGalleryTags: showGalleryTags ?? this.showGalleryTags,
    hideGalleryThumbnails: hideGalleryThumbnails ?? this.hideGalleryThumbnails,
    horizontalThumbnails: horizontalThumbnails ?? this.horizontalThumbnails,
    pHashThreshold: pHashThreshold ?? this.pHashThreshold,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhConfig && jpnTitleInGalleryPage == other.jpnTitleInGalleryPage && tagTranslat == other.tagTranslat && tagTranslatVer == other.tagTranslatVer && favoritesOrder == other.favoritesOrder && siteEx == other.siteEx && galleryImgBlur == other.galleryImgBlur && favPicker == other.favPicker && favLongTap == other.favLongTap && lastFavcat == other.lastFavcat && lastShowFavcat == other.lastShowFavcat && lastShowFavTitle == other.lastShowFavTitle && listMode == other.listMode && safeMode == other.safeMode && catFilter == other.catFilter && maxHistory == other.maxHistory && searchBarComp == other.searchBarComp && pureDarkTheme == other.pureDarkTheme && viewModel == other.viewModel && clipboardLink == other.clipboardLink && commentTrans == other.commentTrans && autoLockTimeOut == other.autoLockTimeOut && showPageInterval == other.showPageInterval && orientation == other.orientation && vibrate == other.vibrate && tagIntroImgLv == other.tagIntroImgLv && debugMode == other.debugMode && debugCount == other.debugCount && autoRead == other.autoRead && turnPageInv == other.turnPageInv && toplist == other.toplist && tabletLayout == other.tabletLayout && tabletLayoutValue == other.tabletLayoutValue && enableTagTranslateCDN == other.enableTagTranslateCDN && autoSelectProfile == other.autoSelectProfile && turnPageAnimations == other.turnPageAnimations && selectProfile == other.selectProfile && linkRedirect == other.linkRedirect && viewColumnMode == other.viewColumnMode && fixedHeightOfListItems == other.fixedHeightOfListItems && tagTranslateDataUpdateMode == other.tagTranslateDataUpdateMode && showCommentAvatar == other.showCommentAvatar && avatarType == other.avatarType && boringAvatarsType == other.boringAvatarsType && textAvatarsType == other.textAvatarsType && avatarBorderRadiusType == other.avatarBorderRadiusType && enablePHashCheck == other.enablePHashCheck && enableQRCodeCheck == other.enableQRCodeCheck && viewFullscreen == other.viewFullscreen && blurringOfCoverBackground == other.blurringOfCoverBackground && listViewTagLimit == other.listViewTagLimit && redirectThumbLink == other.redirectThumbLink && volumnTurnPage == other.volumnTurnPage && proxyType == other.proxyType && proxyHost == other.proxyHost && proxyPort == other.proxyPort && proxyUsername == other.proxyUsername && proxyPassword == other.proxyPassword && webDAVMaxConnections == other.webDAVMaxConnections && hideTopBarOnScroll == other.hideTopBarOnScroll && readViewCompatibleMode == other.readViewCompatibleMode && translateSearchHistory == other.translateSearchHistory && nativeHttpClientAdapter == other.nativeHttpClientAdapter && showComments == other.showComments && showOnlyUploaderComment == other.showOnlyUploaderComment && showGalleryTags == other.showGalleryTags && hideGalleryThumbnails == other.hideGalleryThumbnails && horizontalThumbnails == other.horizontalThumbnails && pHashThreshold == other.pHashThreshold;

  @override
  int get hashCode => jpnTitleInGalleryPage.hashCode ^ tagTranslat.hashCode ^ tagTranslatVer.hashCode ^ favoritesOrder.hashCode ^ siteEx.hashCode ^ galleryImgBlur.hashCode ^ favPicker.hashCode ^ favLongTap.hashCode ^ lastFavcat.hashCode ^ lastShowFavcat.hashCode ^ lastShowFavTitle.hashCode ^ listMode.hashCode ^ safeMode.hashCode ^ catFilter.hashCode ^ maxHistory.hashCode ^ searchBarComp.hashCode ^ pureDarkTheme.hashCode ^ viewModel.hashCode ^ clipboardLink.hashCode ^ commentTrans.hashCode ^ autoLockTimeOut.hashCode ^ showPageInterval.hashCode ^ orientation.hashCode ^ vibrate.hashCode ^ tagIntroImgLv.hashCode ^ debugMode.hashCode ^ debugCount.hashCode ^ autoRead.hashCode ^ turnPageInv.hashCode ^ toplist.hashCode ^ tabletLayout.hashCode ^ tabletLayoutValue.hashCode ^ enableTagTranslateCDN.hashCode ^ autoSelectProfile.hashCode ^ turnPageAnimations.hashCode ^ selectProfile.hashCode ^ linkRedirect.hashCode ^ viewColumnMode.hashCode ^ fixedHeightOfListItems.hashCode ^ tagTranslateDataUpdateMode.hashCode ^ showCommentAvatar.hashCode ^ avatarType.hashCode ^ boringAvatarsType.hashCode ^ textAvatarsType.hashCode ^ avatarBorderRadiusType.hashCode ^ enablePHashCheck.hashCode ^ enableQRCodeCheck.hashCode ^ viewFullscreen.hashCode ^ blurringOfCoverBackground.hashCode ^ listViewTagLimit.hashCode ^ redirectThumbLink.hashCode ^ volumnTurnPage.hashCode ^ proxyType.hashCode ^ proxyHost.hashCode ^ proxyPort.hashCode ^ proxyUsername.hashCode ^ proxyPassword.hashCode ^ webDAVMaxConnections.hashCode ^ hideTopBarOnScroll.hashCode ^ readViewCompatibleMode.hashCode ^ translateSearchHistory.hashCode ^ nativeHttpClientAdapter.hashCode ^ showComments.hashCode ^ showOnlyUploaderComment.hashCode ^ showGalleryTags.hashCode ^ hideGalleryThumbnails.hashCode ^ horizontalThumbnails.hashCode ^ pHashThreshold.hashCode;
}
