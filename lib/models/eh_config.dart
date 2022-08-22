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
    this.tapToTurnPageAnimations,
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
  final bool? tapToTurnPageAnimations;
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
    tapToTurnPageAnimations: json['tapToTurnPageAnimations'] != null ? json['tapToTurnPageAnimations'] as bool : null,
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
    listViewTagLimit: json['listViewTagLimit'] != null ? json['listViewTagLimit'] as int : null
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
    'tapToTurnPageAnimations': tapToTurnPageAnimations,
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
    'listViewTagLimit': listViewTagLimit
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
    tapToTurnPageAnimations: tapToTurnPageAnimations,
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
    listViewTagLimit: listViewTagLimit
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
    bool? tapToTurnPageAnimations,
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
    int? listViewTagLimit
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
    tapToTurnPageAnimations: tapToTurnPageAnimations ?? this.tapToTurnPageAnimations,
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
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhConfig && jpnTitle == other.jpnTitle && tagTranslat == other.tagTranslat && tagTranslatVer == other.tagTranslatVer && favoritesOrder == other.favoritesOrder && siteEx == other.siteEx && galleryImgBlur == other.galleryImgBlur && favPicker == other.favPicker && favLongTap == other.favLongTap && lastFavcat == other.lastFavcat && lastShowFavcat == other.lastShowFavcat && lastShowFavTitle == other.lastShowFavTitle && listMode == other.listMode && safeMode == other.safeMode && catFilter == other.catFilter && maxHistory == other.maxHistory && searchBarComp == other.searchBarComp && pureDarkTheme == other.pureDarkTheme && viewModel == other.viewModel && clipboardLink == other.clipboardLink && commentTrans == other.commentTrans && autoLockTimeOut == other.autoLockTimeOut && showPageInterval == other.showPageInterval && orientation == other.orientation && vibrate == other.vibrate && tagIntroImgLv == other.tagIntroImgLv && debugMode == other.debugMode && debugCount == other.debugCount && autoRead == other.autoRead && turnPageInv == other.turnPageInv && toplist == other.toplist && tabletLayout == other.tabletLayout && tabletLayoutValue == other.tabletLayoutValue && enableTagTranslateCDN == other.enableTagTranslateCDN && autoSelectProfile == other.autoSelectProfile && tapToTurnPageAnimations == other.tapToTurnPageAnimations && selectProfile == other.selectProfile && linkRedirect == other.linkRedirect && viewColumnMode == other.viewColumnMode && fixedHeightOfListItems == other.fixedHeightOfListItems && tagTranslateDataUpdateMode == other.tagTranslateDataUpdateMode && showCommentAvatar == other.showCommentAvatar && avatarType == other.avatarType && boringAvatarsType == other.boringAvatarsType && textAvatarsType == other.textAvatarsType && avatarBorderRadiusType == other.avatarBorderRadiusType && enablePHashCheck == other.enablePHashCheck && enableQRCodeCheck == other.enableQRCodeCheck && viewFullscreen == other.viewFullscreen && blurringOfCoverBackground == other.blurringOfCoverBackground && listViewTagLimit == other.listViewTagLimit;

  @override
  int get hashCode => jpnTitle.hashCode ^ tagTranslat.hashCode ^ tagTranslatVer.hashCode ^ favoritesOrder.hashCode ^ siteEx.hashCode ^ galleryImgBlur.hashCode ^ favPicker.hashCode ^ favLongTap.hashCode ^ lastFavcat.hashCode ^ lastShowFavcat.hashCode ^ lastShowFavTitle.hashCode ^ listMode.hashCode ^ safeMode.hashCode ^ catFilter.hashCode ^ maxHistory.hashCode ^ searchBarComp.hashCode ^ pureDarkTheme.hashCode ^ viewModel.hashCode ^ clipboardLink.hashCode ^ commentTrans.hashCode ^ autoLockTimeOut.hashCode ^ showPageInterval.hashCode ^ orientation.hashCode ^ vibrate.hashCode ^ tagIntroImgLv.hashCode ^ debugMode.hashCode ^ debugCount.hashCode ^ autoRead.hashCode ^ turnPageInv.hashCode ^ toplist.hashCode ^ tabletLayout.hashCode ^ tabletLayoutValue.hashCode ^ enableTagTranslateCDN.hashCode ^ autoSelectProfile.hashCode ^ tapToTurnPageAnimations.hashCode ^ selectProfile.hashCode ^ linkRedirect.hashCode ^ viewColumnMode.hashCode ^ fixedHeightOfListItems.hashCode ^ tagTranslateDataUpdateMode.hashCode ^ showCommentAvatar.hashCode ^ avatarType.hashCode ^ boringAvatarsType.hashCode ^ textAvatarsType.hashCode ^ avatarBorderRadiusType.hashCode ^ enablePHashCheck.hashCode ^ enableQRCodeCheck.hashCode ^ viewFullscreen.hashCode ^ blurringOfCoverBackground.hashCode ^ listViewTagLimit.hashCode;
}
