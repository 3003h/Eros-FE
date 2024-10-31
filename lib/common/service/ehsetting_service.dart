import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:eros_fe/common/controller/webdav_controller.dart';
import 'package:eros_fe/common/service/base_service.dart';
import 'package:eros_fe/const/storages.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/app_dio/proxy.dart';
import 'package:eros_fe/pages/gallery/view/sliver/gallery_page.dart';
import 'package:eros_fe/pages/image_view/common.dart';
import 'package:eros_fe/pages/image_view/controller/view_controller.dart';
import 'package:eros_fe/pages/image_view/view/view_page.dart';
import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:eros_fe/pages/tab/controller/toplist_controller.dart';
import 'package:eros_fe/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'controller_tag_service.dart';
import 'locale_service.dart';

class EhSettingService extends ProfileService {
  // RxBool isJpnTitle = false.obs;
  // RxBool isTagTranslat = false.obs;
  RxBool isGalleryImgBlur = false.obs;
  RxBool isSiteEx = false.obs;
  RxBool isFavLongTap = false.obs;
  RxInt catFilter = 0.obs;
  Rx<ListModeEnum> listMode = ListModeEnum.list.obs;
  // RxInt maxHistory = 100.obs;
  RxBool isSearchBarComp = true.obs;
  Rx<FavoriteOrder> favoriteOrder = FavoriteOrder.fav.obs;
  RxBool isSafeMode = false.obs;
  RxString tagTranslatVer = ''.obs;
  RxBool isFavPicker = false.obs;
  // RxBool isPureDarkTheme = false.obs;
  RxBool isClipboardLink = true.obs;
  RxBool commentTrans = false.obs;
  // RxBool blurredInRecentTasks = true.obs;
  Rx<TagIntroImgLv> tagIntroImgLv = TagIntroImgLv.nonh.obs;

  final _isPureDarkTheme = false.obs;
  bool get isPureDarkTheme => _isPureDarkTheme.value;
  set isPureDarkTheme(bool val) => _isPureDarkTheme.value = val;

  final _blurredInRecentTasks = false.obs;
  bool get blurredInRecentTasks => _blurredInRecentTasks.value;
  set blurredInRecentTasks(bool val) => _blurredInRecentTasks.value = val;

  final _viewColumnMode = ViewColumnMode.single.obs;
  ViewColumnMode get viewColumnMode => _viewColumnMode.value;
  set viewColumnMode(ViewColumnMode val) => _viewColumnMode.value = val;

  final _lastFavcat = '0'.obs;
  String get lastFavcat => _lastFavcat.value;
  set lastFavcat(String val) => _lastFavcat.value = val;

  final LocaleService localeService = Get.find();

  final _isTagTranslate = false.obs;
  bool get isTagTranslate {
    return localeService.isLanguageCodeZh && _isTagTranslate.value;
  }

  set isTagTranslate(bool val) => _isTagTranslate.value = val;

  String _lastClipboardLink = '';

  String? get lastShowFavcat => ehConfig.lastShowFavcat;
  set lastShowFavcat(String? value) {
    ehConfig = ehConfig.copyWith(lastShowFavcat: value.oN);
  }

  String? get lastShowFavTitle => ehConfig.lastShowFavTitle;
  set lastShowFavTitle(String? value) {
    ehConfig = ehConfig.copyWith(lastShowFavTitle: value.oN);
    Global.saveProfile();
  }

  /// 预载图片数量
  RxInt preloadImage = 2.obs;

  /// 下载线程数
  final RxInt _multiDownload = 1.obs;
  int get multiDownload => _multiDownload.value;
  set multiDownload(int val) => _multiDownload.value = val;

  // 允许媒体扫描
  final RxBool _allowMediaScan = false.obs;
  bool get allowMediaScan => _allowMediaScan.value;
  set allowMediaScan(bool val) => _allowMediaScan.value = val;

  final RxBool _enableTagTranslateCDN = false.obs;
  bool get enableTagTranslateCDN => _enableTagTranslateCDN.value;
  set enableTagTranslateCDN(bool val) => _enableTagTranslateCDN.value = val;

  /// 阅读相关设置
  /// 阅读方向
  Rx<ViewMode> viewMode = ViewMode.leftToRight.obs;

  /// 自动锁定时间
  RxInt autoLockTimeOut = (-1).obs;

  /// 屏幕方向
  Rx<ReadOrientation> orientation = ReadOrientation.system.obs;

  /// 显示页面间隔
  RxBool showPageInterval = true.obs;

  // 震动总开关
  RxBool vibrate = true.obs;

  final RxBool _debugMode = false.obs;
  bool get debugMode => _debugMode.value;
  set debugMode(bool val) => _debugMode.value = val;

  final RxString _downloadLocatino = ''.obs;
  String get downloadLocatino => _downloadLocatino.value;
  set downloadLocatino(String val) => _downloadLocatino.value = val;

  // 自动翻页 _autoRead
  final RxBool _autoRead = false.obs;
  bool get autoRead => _autoRead.value;
  set autoRead(bool val) => _autoRead.value = val;

  // 翻页时间间隔 _turnPageInv
  final RxInt _turnPageInv = 3000.obs;
  int get turnPageInv => _turnPageInv.value;
  set turnPageInv(int val) => _turnPageInv.value = val;

  // toplists
  final _toplist = ToplistType.yesterday.obs;
  ToplistType get toplist => _toplist.value;
  set toplist(ToplistType val) => _toplist.value = val;

  int debugCount = 3;

  // final _tabletLayout = true.obs;
  // bool get tabletLayout => _tabletLayout.value;
  // set tabletLayout(bool val) => _tabletLayout.value = val;

  final _autoSelectProfile = true.obs;
  bool get autoSelectProfile => _autoSelectProfile.value;
  set autoSelectProfile(bool val) => _autoSelectProfile.value = val;

  final _turnPageAnimations = true.obs;
  bool get turnPageAnimations => _turnPageAnimations.value;
  set turnPageAnimations(bool val) => _turnPageAnimations.value = val;

  final _downloadOrigImage = false.obs;
  bool get downloadOrigImage => _downloadOrigImage.value;
  set downloadOrigImage(bool val) => _downloadOrigImage.value = val;

  final _downloadOrigType = DownloadOrigImageType.no.obs;
  DownloadOrigImageType get downloadOrigType => _downloadOrigType.value;
  set downloadOrigType(DownloadOrigImageType val) =>
      _downloadOrigType.value = val;

  final _selectProfile = ''.obs;
  String get selectProfile => _selectProfile.value;
  set selectProfile(String val) => _selectProfile.value = val;

  final _linkRedirect = false.obs;
  bool get linkRedirect => _linkRedirect.value;
  set linkRedirect(bool val) => _linkRedirect.value = val;

  final _fixedHeightOfListItems = true.obs;
  bool get fixedHeightOfListItems => _fixedHeightOfListItems.value;
  set fixedHeightOfListItems(bool val) => _fixedHeightOfListItems.value = val;

  final _tagTranslateDataUpdateMode = TagTranslateDataUpdateMode.manual.obs;
  TagTranslateDataUpdateMode get tagTranslateDataUpdateMode =>
      _tagTranslateDataUpdateMode.value;
  set tagTranslateDataUpdateMode(TagTranslateDataUpdateMode val) =>
      _tagTranslateDataUpdateMode.value = val;

  final _tabletLayoutType = TabletLayout.automatic.obs;
  TabletLayout get tabletLayoutType => _tabletLayoutType.value;
  set tabletLayoutType(TabletLayout val) => _tabletLayoutType.value = val;

  final _showCommentAvatar = false.obs;
  bool get showCommentAvatar => _showCommentAvatar.value;
  set showCommentAvatar(bool val) => _showCommentAvatar.value = val;

  final _boringAvatarsType = BoringAvatarType.beam.obs;
  BoringAvatarType get boringAvatarsType => _boringAvatarsType.value;
  set boringAvatarsType(BoringAvatarType val) => _boringAvatarsType.value = val;

  final _avatarBorderRadiusType = AvatarBorderRadiusType.circle.obs;
  AvatarBorderRadiusType get avatarBorderRadiusType =>
      _avatarBorderRadiusType.value;
  set avatarBorderRadiusType(AvatarBorderRadiusType val) =>
      _avatarBorderRadiusType.value = val;

  final _enablePHashCheck = false.obs;
  bool get enablePHashCheck => _enablePHashCheck.value;
  set enablePHashCheck(bool val) => _enablePHashCheck.value = val;

  final _enableQRCodeCheck = false.obs;
  bool get enableQRCodeCheck => _enableQRCodeCheck.value;
  set enableQRCodeCheck(bool val) => _enableQRCodeCheck.value = val;

  final _viewFullscreen = false.obs;
  bool get viewFullscreen => _viewFullscreen.value;
  set viewFullscreen(bool val) => _viewFullscreen.value = val;

  final _blurringOfCoverBackground = false.obs;
  bool get blurringOfCoverBackground => _blurringOfCoverBackground.value;
  set blurringOfCoverBackground(bool val) =>
      _blurringOfCoverBackground.value = val;

  static const _kAvatarType = AvatarType.textAvatar;
  final _avatarType = _kAvatarType.obs;
  AvatarType get avatarType => _avatarType.value;
  set avatarType(AvatarType val) => _avatarType.value = val;

  static const _kTextAvatarsType = TextAvatarsType.firstText;
  final _textAvatarsType = _kTextAvatarsType.obs;
  TextAvatarsType get textAvatarsType => _textAvatarsType.value;
  set textAvatarsType(TextAvatarsType val) => _textAvatarsType.value = val;

  final _listViewTagLimit = (-1).obs;
  int get listViewTagLimit => _listViewTagLimit.value;
  set listViewTagLimit(int val) => _listViewTagLimit.value = val;

  final _redirectThumbLink = true.obs;
  bool get redirectThumbLink => _redirectThumbLink.value;
  set redirectThumbLink(bool val) => _redirectThumbLink.value = val;

  final _volumnTurnPage = false.obs;
  bool get volumnTurnPage => _volumnTurnPage.value;
  set volumnTurnPage(bool val) => _volumnTurnPage.value = val;

  final _proxyType = ProxyType.system.obs;
  ProxyType get proxyType => _proxyType.value;
  set proxyType(ProxyType val) => _proxyType.value = val;

  final _proxyHost = ''.obs;
  String get proxyHost => _proxyHost.value;
  set proxyHost(String val) => _proxyHost.value = val;

  final _proxyPort = 1080.obs;
  int get proxyPort => _proxyPort.value;
  set proxyPort(int val) => _proxyPort.value = val;

  final _proxyUsername = ''.obs;
  String get proxyUsername => _proxyUsername.value;
  set proxyUsername(String val) => _proxyUsername.value = val;

  final _proxyPassword = ''.obs;
  String get proxyPassword => _proxyPassword.value;
  set proxyPassword(String val) => _proxyPassword.value = val;

  // webDAVMaxConnections
  final _webDAVMaxConnections = 3.obs;
  int get webDAVMaxConnections => _webDAVMaxConnections.value;
  set webDAVMaxConnections(int val) => _webDAVMaxConnections.value = val;

  // hideTopBarOnScroll
  final _hideTopBarOnScroll = false.obs;
  bool get hideTopBarOnScroll => _hideTopBarOnScroll.value;
  set hideTopBarOnScroll(bool val) => _hideTopBarOnScroll.value = val;

  final _itemConfigList = <ItemConfig>[].obs;
  final _itemConfigMap = <ListModeEnum, ItemConfig>{}.obs;
  Map<ListModeEnum, ItemConfig> get mapItemConfig => _itemConfigMap;

  ItemConfig? getItemConfig([ListModeEnum? mode]) {
    return _itemConfigMap[mode ?? listMode.value];
  }

  void setItemConfig(ListModeEnum mode, ItemConfig Function(ItemConfig) func) {
    _itemConfigMap[mode] = func(_itemConfigMap[mode] ??
        ItemConfig(type: EnumToString.convertToString(mode)));
    _itemConfigList(List.from(_itemConfigMap.values));
  }

  // readViewCompatibleModes
  final _readViewCompatibleMode = true.obs;
  // bool get readViewCompatibleMode => _readViewCompatibleMode.value;
  bool get readViewCompatibleMode => true;
  set readViewCompatibleMode(bool val) => _readViewCompatibleMode.value = val;

  // pageViewType
  final _pageViewType = PageViewType.extendedImageGesturePageView.obs;
  PageViewType get pageViewType => _pageViewType.value;
  set pageViewType(PageViewType val) => _pageViewType.value = val;

  // translateSearchHistory
  final _translateSearchHistory = true.obs;
  bool get translateSearchHistory => _translateSearchHistory.value;
  set translateSearchHistory(bool val) => _translateSearchHistory.value = val;

  // nativeHttpClientAdapter
  final _nativeHttpClientAdapter = false.obs;
  bool get nativeHttpClientAdapter => _nativeHttpClientAdapter.value;
  set nativeHttpClientAdapter(bool val) => _nativeHttpClientAdapter.value = val;

  // jpnTitleInGalleryPage
  final _jpnTitleInGalleryPage = false.obs;
  bool get jpnTitleInGalleryPage => _jpnTitleInGalleryPage.value;
  set jpnTitleInGalleryPage(bool val) => _jpnTitleInGalleryPage.value = val;

  // _showComments
  final _showComments = true.obs;
  bool get showComments => _showComments.value;
  set showComments(bool val) => _showComments.value = val;

  // showGalleryTags
  final _showGalleryTags = true.obs;
  bool get showGalleryTags => _showGalleryTags.value;
  set showGalleryTags(bool val) => _showGalleryTags.value = val;

  // showOnlyUploaderComment
  final _showOnlyUploaderComment = false.obs;
  bool get showOnlyUploaderComment => _showOnlyUploaderComment.value;
  set showOnlyUploaderComment(bool val) => _showOnlyUploaderComment.value = val;

  // hideGalleryThumbnails
  final _hideGalleryThumbnails = false.obs;
  bool get hideGalleryThumbnails => _hideGalleryThumbnails.value;
  set hideGalleryThumbnails(bool val) => _hideGalleryThumbnails.value = val;

  // horizontalThumbnails
  final _horizontalThumbnails = false.obs;
  bool get horizontalThumbnails => _horizontalThumbnails.value;
  set horizontalThumbnails(bool val) => _horizontalThumbnails.value = val;

  // pHashThreshold
  final _pHashThreshold = 10.obs;
  int get pHashThreshold => _pHashThreshold.value;
  set pHashThreshold(int val) => _pHashThreshold.value = val;

  // enableSlideOutPage
  final _enableSlideOutPage = true.obs;
  bool get enableSlideOutPage => _enableSlideOutPage.value;
  set enableSlideOutPage(bool val) => _enableSlideOutPage.value = val;

  void _initEhConfig() {
    // pageViewType
    pageViewType = EnumToString.fromString(
            PageViewType.values, ehConfig.pageViewType ?? '') ??
        pageViewType;
    everFromEnum(_pageViewType, (String value) {
      ehConfig = ehConfig.copyWith(pageViewType: value.oN);
    });

    // pHashThreshold
    pHashThreshold = ehConfig.pHashThreshold ?? pHashThreshold;
    everProfile<int>(_pHashThreshold, (val) {
      ehConfig = ehConfig.copyWith(pHashThreshold: val.oN);
    });

    // hideGalleryThumbnails
    hideGalleryThumbnails =
        ehConfig.hideGalleryThumbnails ?? hideGalleryThumbnails;
    everProfile<bool>(_hideGalleryThumbnails, (val) {
      ehConfig = ehConfig.copyWith(hideGalleryThumbnails: val.oN);
    });

    // horizontalThumbnails
    horizontalThumbnails =
        ehConfig.horizontalThumbnails ?? horizontalThumbnails;
    everProfile<bool>(_horizontalThumbnails, (val) {
      ehConfig = ehConfig.copyWith(horizontalThumbnails: val.oN);
    });

    // showComments
    showComments = ehConfig.showComments ?? showComments;
    everProfile<bool>(_showComments, (val) {
      ehConfig = ehConfig.copyWith(showComments: val.oN);
    });

    // showOnlyUploaderComment
    showOnlyUploaderComment =
        ehConfig.showOnlyUploaderComment ?? showOnlyUploaderComment;
    everProfile<bool>(_showOnlyUploaderComment, (val) {
      ehConfig = ehConfig.copyWith(showOnlyUploaderComment: val.oN);
    });

    // showGalleryTags
    showGalleryTags = ehConfig.showGalleryTags ?? showGalleryTags;
    everProfile<bool>(_showGalleryTags, (val) {
      ehConfig = ehConfig.copyWith(showGalleryTags: val.oN);
    });

    // jpnTitleInGalleryPage
    jpnTitleInGalleryPage =
        ehConfig.jpnTitleInGalleryPage ?? jpnTitleInGalleryPage;
    everProfile<bool>(_jpnTitleInGalleryPage, (val) {
      ehConfig = ehConfig.copyWith(jpnTitleInGalleryPage: val.oN);
    });

    // nativeHttpClientAdapter
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      nativeHttpClientAdapter =
          ehConfig.nativeHttpClientAdapter ?? nativeHttpClientAdapter;
    } else {
      nativeHttpClientAdapter = false;
    }
    everProfile<bool>(_nativeHttpClientAdapter, (val) {
      ehConfig = ehConfig.copyWith(nativeHttpClientAdapter: val.oN);
    });

    // readViewCompatibleModes
    readViewCompatibleMode =
        ehConfig.readViewCompatibleMode ?? readViewCompatibleMode;
    everProfile<bool>(_readViewCompatibleMode, (val) {
      ehConfig = ehConfig.copyWith(readViewCompatibleMode: val.oN);
      if (Get.isRegistered<ViewExtController>()) {
        Get.find<ViewExtController>().update([idSlidePage]);
      }
    });

    // translateSearchHistory
    translateSearchHistory =
        ehConfig.translateSearchHistory ?? translateSearchHistory;
    everProfile<bool>(_translateSearchHistory, (val) {
      ehConfig = ehConfig.copyWith(translateSearchHistory: val.oN);
    });

    // hideTopBarOnScroll
    hideTopBarOnScroll = ehConfig.hideTopBarOnScroll ?? hideTopBarOnScroll;
    everProfile<bool>(_hideTopBarOnScroll, (value) {
      ehConfig = ehConfig.copyWith(hideTopBarOnScroll: value.oN);
    });

    // webDAVMaxConnections
    webDAVMaxConnections =
        ehConfig.webDAVMaxConnections ?? webDAVMaxConnections;
    everProfile<int>(_webDAVMaxConnections, (value) {
      if (Get.isRegistered<WebdavController>()) {
        Get.find<WebdavController>().resetExecutorConcurrency(value);
      }
      ehConfig = ehConfig.copyWith(webDAVMaxConnections: value.oN);
    });

    proxyType =
        EnumToString.fromString(ProxyType.values, ehConfig.proxyType ?? '') ??
            proxyType;
    everFromEnum(_proxyType, (String value) {
      ehConfig = ehConfig.copyWith(proxyType: value.oN);
      setProxy();
    });

    proxyHost = ehConfig.proxyHost ?? proxyHost;
    everProfile<String>(_proxyHost, (value) {
      ehConfig = ehConfig.copyWith(proxyHost: value.oN);
      setProxy();
    });

    proxyPort = ehConfig.proxyPort ?? proxyPort;
    everProfile<int>(_proxyPort, (value) {
      ehConfig = ehConfig.copyWith(proxyPort: value.oN);
      setProxy();
    });

    proxyUsername = ehConfig.proxyUsername ?? proxyUsername;
    everProfile<String>(_proxyUsername, (value) {
      ehConfig = ehConfig.copyWith(proxyUsername: value.oN);
      setProxy();
    });

    proxyPassword = ehConfig.proxyPassword ?? proxyPassword;
    everProfile<String>(_proxyPassword, (value) {
      ehConfig = ehConfig.copyWith(proxyPassword: value.oN);
      setProxy();
    });

    volumnTurnPage = ehConfig.volumnTurnPage ?? volumnTurnPage;
    everProfile<bool>(_volumnTurnPage, (value) {
      ehConfig = ehConfig.copyWith(volumnTurnPage: value.oN);
    });

    redirectThumbLink = ehConfig.redirectThumbLink ?? redirectThumbLink;
    everProfile<bool>(_redirectThumbLink, (value) {
      ehConfig = ehConfig.copyWith(redirectThumbLink: value.oN);
    });

    listViewTagLimit = ehConfig.listViewTagLimit ?? listViewTagLimit;
    everProfile<int>(_listViewTagLimit, (value) {
      ehConfig = ehConfig.copyWith(listViewTagLimit: value.oN);
    });

    avatarType =
        EnumToString.fromString(AvatarType.values, ehConfig.avatarType ?? '') ??
            _kAvatarType;
    everFromEnum(_avatarType, (String value) {
      ehConfig = ehConfig.copyWith(avatarType: value.oN);
    });

    textAvatarsType = EnumToString.fromString(
            TextAvatarsType.values, ehConfig.textAvatarsType ?? '') ??
        _kTextAvatarsType;
    everFromEnum(_textAvatarsType, (String value) {
      ehConfig = ehConfig.copyWith(textAvatarsType: value.oN);
    });

    blurringOfCoverBackground =
        ehConfig.blurringOfCoverBackground ?? blurringOfCoverBackground;
    everProfile<bool>(_blurringOfCoverBackground, (value) {
      ehConfig = ehConfig.copyWith(blurringOfCoverBackground: value.oN);
    });

    viewFullscreen = ehConfig.viewFullscreen ?? viewFullscreen;
    everProfile<bool>(_viewFullscreen, (value) {
      ehConfig = ehConfig.copyWith(viewFullscreen: value.oN);
    });

    enablePHashCheck = ehConfig.enablePHashCheck ?? enablePHashCheck;
    everProfile<bool>(_enablePHashCheck, (value) {
      ehConfig = ehConfig.copyWith(enablePHashCheck: value.oN);
    });

    enableQRCodeCheck = ehConfig.enableQRCodeCheck ?? enableQRCodeCheck;
    everProfile<bool>(_enableQRCodeCheck, (value) {
      ehConfig = ehConfig.copyWith(enableQRCodeCheck: value.oN);
    });

    // _boringAvatarsType
    boringAvatarsType = EnumToString.fromString(
            BoringAvatarType.values, ehConfig.boringAvatarsType ?? '') ??
        BoringAvatarType.beam;
    everFromEnum(_boringAvatarsType, (String value) {
      ehConfig = ehConfig.copyWith(boringAvatarsType: value.oN);
    });

    // _avatarBorderRadiusType
    avatarBorderRadiusType = EnumToString.fromString(
            AvatarBorderRadiusType.values,
            ehConfig.avatarBorderRadiusType ?? '') ??
        avatarBorderRadiusType;
    everFromEnum(_avatarBorderRadiusType, (String value) {
      ehConfig = ehConfig.copyWith(avatarBorderRadiusType: value.oN);
    });

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, ehConfig.viewModel) ??
            viewMode.value;
    everFromEnum(viewMode, (String value) {
      ehConfig = ehConfig.copyWith(viewModel: value);
    });

    //
    isSafeMode.value = ehConfig.safeMode ?? isSafeMode.value;
    everProfile<bool>(isSafeMode, (value) {
      ehConfig = ehConfig.copyWith(safeMode: value.oN);
      Get.find<TabHomeController>().resetIndex();
    });

    // isJpnTitle.value = ehConfig.jpnTitle;
    // everProfile<bool>(isJpnTitle, (value) {
    //   ehConfig = ehConfig.copyWith(jpnTitle: value);
    // });

    isTagTranslate = ehConfig.tagTranslat ?? isTagTranslate;
    everProfile<bool>(_isTagTranslate,
        (value) => ehConfig = ehConfig.copyWith(tagTranslat: value.oN));

    isGalleryImgBlur.value = ehConfig.galleryImgBlur ?? isGalleryImgBlur.value;
    everProfile<bool>(isGalleryImgBlur,
        (value) => ehConfig = ehConfig.copyWith(galleryImgBlur: value.oN));

    isSiteEx.value = ehConfig.siteEx ?? isSiteEx.value;
    // 初始化
    switchGlobalDioConfig(isSiteEx.value);
    everProfile<bool>(isSiteEx, (value) {
      logger.d('everProfile isSiteEx');
      ehConfig = ehConfig.copyWith(siteEx: value.oN);
      switchGlobalDioConfig(value);
      // 切换ex后
      Global.initImageHttpClient(
        maxConnectionsPerHost: globalDioConfig.maxConnectionsPerHost,
      );
    });

    isFavLongTap.value = ehConfig.favLongTap ?? isFavLongTap.value;
    everProfile<bool>(isFavLongTap,
        (value) => ehConfig = ehConfig.copyWith(favLongTap: value.oN));

    catFilter.value = ehConfig.catFilter;
    everProfile<int>(
        catFilter, (value) => ehConfig = ehConfig.copyWith(catFilter: value));

    listMode.value =
        EnumToString.fromString(ListModeEnum.values, ehConfig.listMode) ??
            listMode.value;
    everFromEnum(listMode,
        (String value) => ehConfig = ehConfig.copyWith(listMode: value));

    isSearchBarComp.value = ehConfig.searchBarComp ?? isSearchBarComp.value;
    everProfile<bool>(isSearchBarComp,
        (value) => ehConfig = ehConfig.copyWith(searchBarComp: value.oN));

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, ehConfig.favoritesOrder) ??
        favoriteOrder.value;
    everFromEnum(favoriteOrder,
        (String value) => ehConfig = ehConfig.copyWith(favoritesOrder: value));

    tagTranslatVer.value = isarHelper.getTranslateVersion();
    everProfile<String>(tagTranslatVer, (value) {
      // ehConfig = ehConfig.copyWith(tagTranslatVer: value);
      isarHelper.putTagTranslateVersion(value);
    });

    lastFavcat = ehConfig.lastFavcat ?? lastFavcat;
    everProfile<String>(_lastFavcat,
        (value) => ehConfig = ehConfig.copyWith(lastFavcat: value.oN));

    isFavPicker.value = ehConfig.favPicker ?? isFavPicker.value;
    everProfile<bool>(isFavPicker,
        (value) => ehConfig = ehConfig.copyWith(favPicker: value.oN));

    // TODO isPureDarkTheme 暂时禁用
    // isPureDarkTheme = ehConfig.pureDarkTheme ?? isPureDarkTheme;
    isPureDarkTheme = false;
    everProfile<bool>(_isPureDarkTheme,
        (bool value) => ehConfig = ehConfig.copyWith(pureDarkTheme: value.oN));

    isClipboardLink.value = ehConfig.clipboardLink ?? isClipboardLink.value;
    everProfile<bool>(isClipboardLink,
        (bool value) => ehConfig = ehConfig.copyWith(clipboardLink: value.oN));

    commentTrans.value = ehConfig.commentTrans ?? commentTrans.value;
    everProfile<bool>(commentTrans,
        (bool value) => ehConfig = ehConfig.copyWith(commentTrans: value.oN));

    // blurredInRecentTasks
    blurredInRecentTasks =
        storageUtil.getBool(BLURRED_IN_RECENT_TASK) ?? blurredInRecentTasks;
    // applyBlurredInRecentTasks(blurredInRecentTasks);
    everProfile<bool>(_blurredInRecentTasks,
        (bool value) => storageUtil.setBool(BLURRED_IN_RECENT_TASK, value));

    // autoLockTimeOut
    autoLockTimeOut.value = ehConfig.autoLockTimeOut ?? autoLockTimeOut.value;
    everProfile<int>(autoLockTimeOut,
        (int value) => ehConfig = ehConfig.copyWith(autoLockTimeOut: value.oN));

    // showPageInterval
    showPageInterval.value =
        ehConfig.showPageInterval ?? showPageInterval.value;
    everProfile<bool>(
        showPageInterval,
        (bool value) =>
            ehConfig = ehConfig.copyWith(showPageInterval: value.oN));

    // orientation
    orientation.value = EnumToString.fromString(
            ReadOrientation.values, ehConfig.favoritesOrder) ??
        orientation.value;
    everFromEnum(orientation,
        (String value) => ehConfig = ehConfig.copyWith(orientation: value.oN));

    // vibrate
    vibrate.value = ehConfig.vibrate ?? vibrate.value;
    everProfile<bool>(vibrate,
        (bool value) => ehConfig = ehConfig.copyWith(vibrate: value.oN));

    // tagIntroImgLv
    tagIntroImgLv.value = EnumToString.fromString(
            TagIntroImgLv.values, ehConfig.tagIntroImgLv ?? 'nonh') ??
        tagIntroImgLv.value;
    everFromEnum(
        tagIntroImgLv,
        (String value) =>
            ehConfig = ehConfig.copyWith(tagIntroImgLv: value.oN));

    // viewColumnMode
    viewColumnMode = EnumToString.fromString(
            ViewColumnMode.values, ehConfig.viewColumnMode ?? '') ??
        viewColumnMode;
    everFromEnum(
        _viewColumnMode,
        (String value) =>
            ehConfig = ehConfig.copyWith(viewColumnMode: value.oN));

    debugCount = ehConfig.debugCount ?? debugCount;
    if (!kDebugMode) {
      debugCount -= 1;
      ehConfig = ehConfig.copyWith(debugCount: debugCount.oN);
    }
    if (debugCount > 0) {
      debugMode = ehConfig.debugMode ?? false;
    } else {
      debugMode = false;
    }
    Global.saveProfile();
    everProfile<bool>(_debugMode, (bool value) {
      ehConfig = ehConfig.copyWith(debugMode: value.oN, debugCount: 3.oN);
      if (value) {
        Logger.level = Level.debug;
        logger.t('Level.debug');
        ehConfig = ehConfig.copyWith(debugCount: 3.oN);
      } else {
        Logger.level = Level.error;
        ehConfig = ehConfig.copyWith(debugCount: 0.oN);
      }
      resetLogLevel();
    });

    // 自动翻页 _autoRead
    autoRead = ehConfig.autoRead ?? autoRead;
    everProfile<bool>(_autoRead,
        (bool value) => ehConfig = ehConfig.copyWith(autoRead: value.oN));

    // 翻页时间间隔 _turnPageInv
    turnPageInv = ehConfig.turnPageInv ?? turnPageInv;
    everProfile<int>(_turnPageInv,
        (int value) => ehConfig = ehConfig.copyWith(turnPageInv: value.oN));

    toplist =
        EnumToString.fromString(ToplistType.values, ehConfig.toplist ?? '') ??
            toplist;
    everFromEnum(_toplist,
        (String value) => ehConfig = ehConfig.copyWith(toplist: value.oN));

    // tabletLayout = ehConfig.tabletLayout ?? tabletLayout;
    // everProfile<bool>(_tabletLayout,
    //     (bool value) => ehConfig = ehConfig.copyWith(tabletLayout: value));

    enableTagTranslateCDN =
        ehConfig.enableTagTranslateCDN ?? enableTagTranslateCDN;
    everProfile<bool>(
        _enableTagTranslateCDN,
        (bool value) =>
            ehConfig = ehConfig.copyWith(enableTagTranslateCDN: value.oN));

    // _autoSelectProfile
    autoSelectProfile = ehConfig.autoSelectProfile ?? autoSelectProfile;
    everProfile<bool>(
        _autoSelectProfile,
        (bool value) =>
            ehConfig = ehConfig.copyWith(autoSelectProfile: value.oN));

    // tapToTurnPageAnimations
    turnPageAnimations = ehConfig.turnPageAnimations ?? turnPageAnimations;
    everProfile<bool>(
        _turnPageAnimations,
        (bool value) =>
            ehConfig = ehConfig.copyWith(turnPageAnimations: value.oN));

    // _selectProfile
    selectProfile = ehConfig.selectProfile ?? selectProfile;
    everProfile<String>(_selectProfile, (value) {
      ehConfig = ehConfig.copyWith(selectProfile: value.oN);
    });

    // _linkRedirect
    linkRedirect = ehConfig.linkRedirect ?? linkRedirect;
    everProfile<bool>(_linkRedirect, (value) {
      ehConfig = ehConfig.copyWith(linkRedirect: value.oN);
    });

    // fixedHeightOfListItems
    fixedHeightOfListItems =
        ehConfig.fixedHeightOfListItems ?? fixedHeightOfListItems;
    everProfile<bool>(_fixedHeightOfListItems, (value) {
      ehConfig = ehConfig.copyWith(fixedHeightOfListItems: value.oN);
    });

    // tagTranslateDataUpdateMode
    tagTranslateDataUpdateMode = EnumToString.fromString(
            TagTranslateDataUpdateMode.values,
            ehConfig.tagTranslateDataUpdateMode ?? '') ??
        tagTranslateDataUpdateMode;
    everFromEnum(
        _tagTranslateDataUpdateMode,
        (String value) =>
            ehConfig = ehConfig.copyWith(tagTranslateDataUpdateMode: value.oN));

    // tabletLayoutType
    tabletLayoutType = EnumToString.fromString(
            TabletLayout.values, ehConfig.tabletLayoutValue ?? '') ??
        tabletLayoutType;
    everFromEnum(
        _tabletLayoutType,
        (String value) =>
            ehConfig = ehConfig.copyWith(tabletLayoutValue: value.oN));

    // _showCommentAvatar
    showCommentAvatar = ehConfig.showCommentAvatar ?? showCommentAvatar;
    everProfile<bool>(_showCommentAvatar, (value) {
      ehConfig = ehConfig.copyWith(showCommentAvatar: value.oN);
    });

    // _enableSlideOutPage
  }

  ///
  void _initDownloadConfig() {
    /// downloadConfig
    /// 预载图片数量
    preloadImage.value = downloadConfig.preloadImage ?? preloadImage.value;
    everProfile<int>(preloadImage, (value) {
      downloadConfig = downloadConfig.copyWith(preloadImage: value.oN);
    });

    // downloadLocatino
    downloadLocatino = downloadConfig.downloadLocation ?? downloadLocatino;
    everProfile<String>(_downloadLocatino, (value) {
      downloadConfig = downloadConfig.copyWith(downloadLocation: value.oN);
    });

    multiDownload = (downloadConfig.multiDownload != null &&
            downloadConfig.multiDownload! > 0)
        ? downloadConfig.multiDownload!
        : multiDownload;
    everProfile<int>(_multiDownload, (value) {
      downloadConfig = downloadConfig.copyWith(multiDownload: value.oN);
    });

    allowMediaScan = downloadConfig.allowMediaScan ?? allowMediaScan;
    everProfile<bool>(_allowMediaScan, (value) {
      downloadConfig = downloadConfig.copyWith(allowMediaScan: value.oN);
    });

    // downloadOrigImage
    downloadOrigImage = downloadConfig.downloadOrigImage ?? downloadOrigImage;
    everProfile<bool>(_downloadOrigImage, (value) {
      downloadConfig = downloadConfig.copyWith(downloadOrigImage: value.oN);
    });

    // _downloadOrigType
    downloadOrigType = EnumToString.fromString(DownloadOrigImageType.values,
            downloadConfig.downloadOrigImageType ?? '') ??
        (downloadOrigImage
            ? DownloadOrigImageType.askMe
            : DownloadOrigImageType.no);
    everFromEnum(_downloadOrigType, (String value) {
      downloadConfig = downloadConfig.copyWith(downloadOrigImageType: value.oN);
    });

    /// downloadConfig end
  }

  void _initLayoutConfig() {
    _itemConfigList(layoutConfig.itemConfigs);
    for (final itemConfig in _itemConfigList) {
      _itemConfigMap[
          EnumToString.fromString(ListModeEnum.values, itemConfig.type) ??
              ListModeEnum.grid] = itemConfig;
    }

    everProfile<List<ItemConfig>>(_itemConfigList, (val) {
      logger.d('itemConfigList changed: ${val.map((e) => e.toJson())}');
      layoutConfig = layoutConfig.copyWith(itemConfigs: val.oN);
    });
  }

  // _filterCommentsByScore
  final _filterCommentsByScore = false.obs;
  bool get filterCommentsByScore => _filterCommentsByScore.value;
  set filterCommentsByScore(bool val) => _filterCommentsByScore.value = val;

  // _scoreFilteringThreshold
  final _scoreFilteringThreshold = (-20).obs;
  int get scoreFilteringThreshold => _scoreFilteringThreshold.value;
  set scoreFilteringThreshold(int val) => _scoreFilteringThreshold.value = val;

  void _initBlockConfig() {
    // _filterCommentsByScore
    filterCommentsByScore =
        blockConfig.filterCommentsByScore ?? filterCommentsByScore;
    everProfile<bool>(_filterCommentsByScore, (val) {
      blockConfig = blockConfig.copyWith(filterCommentsByScore: val.oN);
    });

    // _scoreFilteringThreshold
    scoreFilteringThreshold =
        blockConfig.scoreFilteringThreshold ?? scoreFilteringThreshold;
    everProfile<int>(_scoreFilteringThreshold, (val) {
      blockConfig = blockConfig.copyWith(scoreFilteringThreshold: val.oN);
    });
  }

  @override
  void onInit() {
    super.onInit();

    _initEhConfig();

    _initDownloadConfig();

    _initLayoutConfig();

    _initBlockConfig();
  }

  void applyBlurredInRecentTasks() {
    if (Platform.isAndroid) {
      if (blurredInRecentTasks) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }
  }

  Future<void> setProxy() async {
    final proxy = await getProxy(
      proxyType: proxyType,
      proxyHost: proxyHost,
      proxyPort: proxyPort,
      proxyUsername: proxyUsername,
      proxyPassword: proxyPassword,
    );

    globalDioConfig = globalDioConfig.copyWith(
      proxy: proxy,
    );
  }

  /// 收藏排序 dialog
  Future<FavoriteOrder?> showFavOrder(BuildContext context) async {
    List<Widget> _getOrderList(BuildContext context) {
      final Map<FavoriteOrder, String> _orderMap = <FavoriteOrder, String>{
        FavoriteOrder.posted: L10n.of(context).favorites_order_Use_posted,
        FavoriteOrder.fav: L10n.of(context).favorites_order_Use_favorited,
      };

      return List<Widget>.from(_orderMap.keys.map((FavoriteOrder element) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Get.back(result: element);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (element == favoriteOrder.value)
                  const SizedBox(
                    width: 40,
                    child: Icon(FontAwesomeIcons.circleCheck),
                  ),
                Text(_orderMap[element] ?? ''),
                if (element == favoriteOrder.value)
                  const SizedBox(
                    width: 40,
                  ),
              ],
            ));
      }).toList());
    }

    final FavoriteOrder? _result = await showCupertinoModalPopup<FavoriteOrder>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(L10n.of(context).favorites_order),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getOrderList(context),
            ],
          );
        });

    if (_result != null) {
      logger.t('to ${EnumToString.convertToString(_result)}');
      if (favoriteOrder.value != _result) {
        return favoriteOrder.value = _result;
      } else {
        return null;
      }
    }
    return _result;
  }

  /// 收藏排序 dialog
  Future<ToplistType?> showToplistsSel(BuildContext context) async {
    List<Widget> _getTopListsText(BuildContext context) {
      final toplistTextMap = <ToplistType, String>{
        ToplistType.yesterday: L10n.of(context).tolist_yesterday,
        ToplistType.month: L10n.of(context).tolist_past_month,
        ToplistType.year: L10n.of(context).tolist_past_year,
        ToplistType.all: L10n.of(context).tolist_alltime,
      };

      return List<Widget>.from(toplistTextMap.keys.map((ToplistType element) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Get.back(result: element);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (element == toplist)
                  const SizedBox(
                    width: 40,
                    child: Icon(FontAwesomeIcons.circleCheck),
                  ),
                Text(toplistTextMap[element] ?? ''),
                if (element == toplist)
                  const SizedBox(
                    width: 40,
                  ),
              ],
            ));
      }).toList());
    }

    final ToplistType? _result = await showCupertinoModalPopup<ToplistType>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getTopListsText(context),
            ],
          );
        });

    if (_result != null) {
      logger.t('to ${EnumToString.convertToString(_result)}');
      if (toplist != _result) {
        return toplist = _result;
      } else {
        return null;
      }
    }
    return _result;
  }

  Future<void> chkClipboardLink(BuildContext context) async {
    if (!isClipboardLink.value) {
      return;
    }

    final String currentRoute = Get.currentRoute;
    logger.d('currentRoute $currentRoute');

    // final List<String> pageNames = <String>[
    //   '/${GalleryMainPage().runtimeType.toString()}',
    //   EHRoutes.galleryPage,
    // ];

    final List<String> pageNames = <String>[
      // '/${const GallerySliverPage().runtimeType.toString()}',
      '/${const GalleryPage().runtimeType.toString()}',
      EHRoutes.galleryPage,
    ];

    final List<String> viewPageNames = <String>[
      '/${const ViewPage().runtimeType.toString()}',
      EHRoutes.galleryViewExt,
    ];

    logger.d('pageNames $pageNames');
    final bool _currentRouteIsGalleryPage = pageNames.contains(currentRoute);

    final bool _replace = viewPageNames.contains(currentRoute);

    final String _text =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (_text.isNotEmpty) {
      logger.d('Clipboard: ' + _text);
    }
    final RegExp _reg =
        RegExp(r'https?://e[-|x]hentai.org/g/(\d+)/([0-9a-f]{10})/?');
    final RegExpMatch? _mach = _reg.firstMatch(_text);
    final gid = _mach?.group(1) ?? '';

    if (_mach == null && (_mach?.group(0)?.isEmpty ?? true)) {
      return;
    }

    if (pageCtrlTag == gid) {
      logger.d('剪贴板链接为当前展示的画廊 返回');
      return;
    }

    // if (_currentRouteIsGalleryPage && _lastClipboardLink == _mach?.group(0)) {
    //   logger.d('剪贴板链接为当前展示的画廊 返回');
    //   return;
    // }

    logger.d('${_mach?.group(0)} ');
    _lastClipboardLink = _mach?.group(0) ?? '';
    if (_lastClipboardLink.isNotEmpty) {
      // _showClipboardLinkDialog(
      //   _lastClipboardLink,
      //   replace: _replace,
      // );

      _showClipboardLinkToast(
        _lastClipboardLink,
        replace: _replace,
      );
    }
  }

  Future<void> _showClipboardLinkToast(
    String url, {
    bool replace = false,
  }) async {
    showActionToast(
      url,
      icon: CupertinoIcons.link,
      onPressed: () {
        NavigatorUtil.goGalleryPage(url: url, forceReplace: replace);
      },
    );
  }

  Future<void> _showClipboardLinkDialog(
    String url, {
    bool replace = false,
  }) async {
    showCupertinoDialog(
        context: Get.overlayContext!,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('画廊跳转'),
            content: const Text('检测到剪贴板中包含画廊链接, 是否打开'),
            actions: [
              CupertinoDialogAction(
                child: Text(L10n.of(context).cancel),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoDialogAction(
                child: Text(L10n.of(context).ok),
                onPressed: () {
                  Get.back();
                  NavigatorUtil.goGalleryPage(url: url, forceReplace: replace);
                },
              ),
            ],
          );
        });
  }
}
