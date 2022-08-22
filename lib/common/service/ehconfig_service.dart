import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/view/sliver/gallery_page_sliver.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../enum.dart';
import 'locale_service.dart';

class EhConfigService extends ProfileService {
  RxBool isJpnTitle = false.obs;
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
  RxString lastFavcat = '0'.obs;
  RxBool isFavPicker = false.obs;
  RxBool isPureDarkTheme = false.obs;
  RxBool isClipboardLink = false.obs;
  RxBool commentTrans = false.obs;
  RxBool blurredInRecentTasks = true.obs;
  Rx<TagIntroImgLv> tagIntroImgLv = TagIntroImgLv.nonh.obs;

  final _viewColumnMode = ViewColumnMode.single.obs;
  ViewColumnMode get viewColumnMode => _viewColumnMode.value;
  set viewColumnMode(ViewColumnMode val) => _viewColumnMode.value = val;

  final LocaleService localeService = Get.find();

  final _isTagTranslat = false.obs;
  bool get isTagTranslat {
    return localeService.isLanguageCodeZh && _isTagTranslat.value;
  }

  set isTagTranslat(bool val) => _isTagTranslat.value = val;

  String _lastClipboardLink = '';

  String? get lastShowFavcat => ehConfig.lastShowFavcat;
  set lastShowFavcat(String? value) {
    ehConfig = ehConfig.copyWith(lastShowFavcat: value);
  }

  String? get lastShowFavTitle => ehConfig.lastShowFavTitle;
  set lastShowFavTitle(String? value) {
    ehConfig = ehConfig.copyWith(lastShowFavTitle: value);
    Global.saveProfile();
  }

  /// 预载图片数量
  RxInt preloadImage = 3.obs;

  /// 下载线程数
  final RxInt _multiDownload = 3.obs;
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
  Rx<ViewMode> viewMode = ViewMode.LeftToRight.obs;

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

  final _tabletLayout = true.obs;
  bool get tabletLayout => _tabletLayout.value;
  set tabletLayout(bool val) => _tabletLayout.value = val;

  final _autoSelectProfile = true.obs;
  bool get autoSelectProfile => _autoSelectProfile.value;
  set autoSelectProfile(bool val) => _autoSelectProfile.value = val;

  final _tapToTurnPageAnimations = true.obs;
  bool get tapToTurnPageAnimations => _tapToTurnPageAnimations.value;
  set tapToTurnPageAnimations(bool val) => _tapToTurnPageAnimations.value = val;

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

  final _boringAvatarsType = BoringAvatarsType.beam.obs;
  BoringAvatarsType get boringAvatarsType => _boringAvatarsType.value;
  set boringAvatarsType(BoringAvatarsType val) =>
      _boringAvatarsType.value = val;

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

  static const _kAvatarType = AvatarType.boringAvatar;
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

  @override
  void onInit() {
    super.onInit();

    listViewTagLimit = ehConfig.listViewTagLimit ?? listViewTagLimit;
    everProfile<int>(_listViewTagLimit, (value) {
      ehConfig = ehConfig.copyWith(listViewTagLimit: value);
    });

    avatarType =
        EnumToString.fromString(AvatarType.values, ehConfig.avatarType ?? '') ??
            _kAvatarType;
    everFromEunm(_avatarType, (String value) {
      ehConfig = ehConfig.copyWith(avatarType: value);
    });

    textAvatarsType = EnumToString.fromString(
            TextAvatarsType.values, ehConfig.textAvatarsType ?? '') ??
        _kTextAvatarsType;
    everFromEunm(_textAvatarsType, (String value) {
      ehConfig = ehConfig.copyWith(textAvatarsType: value);
    });

    blurringOfCoverBackground =
        ehConfig.blurringOfCoverBackground ?? blurringOfCoverBackground;
    everProfile<bool>(_blurringOfCoverBackground, (value) {
      ehConfig = ehConfig.copyWith(blurringOfCoverBackground: value);
    });

    viewFullscreen = ehConfig.viewFullscreen ?? viewFullscreen;
    everProfile<bool>(_viewFullscreen, (value) {
      ehConfig = ehConfig.copyWith(viewFullscreen: value);
    });

    enablePHashCheck = ehConfig.enablePHashCheck ?? enablePHashCheck;
    everProfile<bool>(_enablePHashCheck, (value) {
      ehConfig = ehConfig.copyWith(enablePHashCheck: value);
    });

    enableQRCodeCheck = ehConfig.enableQRCodeCheck ?? enableQRCodeCheck;
    everProfile<bool>(_enableQRCodeCheck, (value) {
      ehConfig = ehConfig.copyWith(enableQRCodeCheck: value);
    });

    // _boringAvatarsType
    boringAvatarsType = EnumToString.fromString(
            BoringAvatarsType.values, ehConfig.boringAvatarsType ?? '') ??
        BoringAvatarsType.beam;
    everFromEunm(_boringAvatarsType, (String value) {
      ehConfig = ehConfig.copyWith(boringAvatarsType: value);
    });

    // _avatarBorderRadiusType
    avatarBorderRadiusType = EnumToString.fromString(
            AvatarBorderRadiusType.values,
            ehConfig.avatarBorderRadiusType ?? '') ??
        avatarBorderRadiusType;
    everFromEunm(_avatarBorderRadiusType, (String value) {
      ehConfig = ehConfig.copyWith(avatarBorderRadiusType: value);
    });

    /// 预载图片数量
    preloadImage.value = downloadConfig.preloadImage ?? preloadImage.value;
    everProfile<int>(preloadImage, (value) {
      downloadConfig = downloadConfig.copyWith(preloadImage: value);
    });

    // downloadLocatino
    downloadLocatino = downloadConfig.downloadLocation ?? downloadLocatino;
    everProfile<String>(_downloadLocatino, (value) {
      downloadConfig = downloadConfig.copyWith(downloadLocation: value);
    });

    multiDownload = (downloadConfig.multiDownload != null &&
            downloadConfig.multiDownload! > 0)
        ? downloadConfig.multiDownload!
        : multiDownload;
    everProfile<int>(_multiDownload, (value) {
      downloadConfig = downloadConfig.copyWith(multiDownload: value);
    });

    allowMediaScan = downloadConfig.allowMediaScan ?? allowMediaScan;
    everProfile<bool>(_allowMediaScan, (value) {
      downloadConfig = downloadConfig.copyWith(allowMediaScan: value);
    });

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, ehConfig.viewModel) ??
            viewMode.value;
    everFromEunm(viewMode, (String value) {
      ehConfig = ehConfig.copyWith(viewModel: value);
    });

    //
    isSafeMode.value = ehConfig.safeMode ?? isSafeMode.value;
    everProfile<bool>(isSafeMode, (value) {
      ehConfig = ehConfig.copyWith(safeMode: value);
      Get.find<TabHomeController>().resetIndex();
    });

    isJpnTitle.value = ehConfig.jpnTitle;
    everProfile<bool>(isJpnTitle, (value) {
      ehConfig = ehConfig.copyWith(jpnTitle: value);
    });

    isTagTranslat = ehConfig.tagTranslat ?? isTagTranslat;
    everProfile<bool>(_isTagTranslat,
        (value) => ehConfig = ehConfig.copyWith(tagTranslat: value));

    isGalleryImgBlur.value = ehConfig.galleryImgBlur ?? isGalleryImgBlur.value;
    everProfile<bool>(isGalleryImgBlur,
        (value) => ehConfig = ehConfig.copyWith(galleryImgBlur: value));

    isSiteEx.value = ehConfig.siteEx ?? isSiteEx.value;
    // 初始化
    ehDioConfig = isSiteEx.value ? exDioConfig : ehDioConfig;
    everProfile(isSiteEx, (value) {
      logger.d('everProfile isSiteEx');
      ehConfig = ehConfig.copyWith(siteEx: value as bool);
      if (value) {
        // 切换ex后
        Global.initImageHttpClient(
            maxConnectionsPerHost: EHConst.exMaxConnectionsPerHost);
        ehDioConfig
          ..baseUrl = exDioConfig.baseUrl
          ..receiveTimeout = exDioConfig.receiveTimeout
          ..connectTimeout = exDioConfig.connectTimeout
          ..maxConnectionsPerHost = exDioConfig.maxConnectionsPerHost;
      } else {
        ehDioConfig
          ..baseUrl = EHConst.EH_BASE_URL
          ..receiveTimeout = ehDioConfig.receiveTimeout
          ..connectTimeout = ehDioConfig.connectTimeout
          ..maxConnectionsPerHost = null;
      }
    });

    isFavLongTap.value = ehConfig.favLongTap ?? isFavLongTap.value;
    everProfile<bool>(isFavLongTap,
        (value) => ehConfig = ehConfig.copyWith(favLongTap: value));

    catFilter.value = ehConfig.catFilter;
    everProfile<int>(
        catFilter, (value) => ehConfig = ehConfig.copyWith(catFilter: value));

    listMode.value =
        EnumToString.fromString(ListModeEnum.values, ehConfig.listMode) ??
            listMode.value;
    everFromEunm(listMode,
        (String value) => ehConfig = ehConfig.copyWith(listMode: value));

    isSearchBarComp.value = ehConfig.searchBarComp ?? isSearchBarComp.value;
    everProfile<bool>(isSearchBarComp,
        (value) => ehConfig = ehConfig.copyWith(searchBarComp: value));

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, ehConfig.favoritesOrder) ??
        favoriteOrder.value;
    everFromEunm(favoriteOrder,
        (String value) => ehConfig = ehConfig.copyWith(favoritesOrder: value));

    tagTranslatVer.value = ehConfig.tagTranslatVer ?? tagTranslatVer.value;
    everProfile<String>(tagTranslatVer,
        (value) => ehConfig = ehConfig.copyWith(tagTranslatVer: value));

    lastFavcat.value = ehConfig.lastFavcat ?? lastFavcat.value;
    everProfile<String>(
        lastFavcat, (value) => ehConfig = ehConfig.copyWith(lastFavcat: value));

    isFavPicker.value = ehConfig.favPicker ?? isFavPicker.value;
    everProfile<bool>(
        isFavPicker, (value) => ehConfig = ehConfig.copyWith(favPicker: value));

    isPureDarkTheme.value = ehConfig.pureDarkTheme ?? isPureDarkTheme.value;
    everProfile<bool>(isPureDarkTheme,
        (bool value) => ehConfig = ehConfig.copyWith(pureDarkTheme: value));

    isClipboardLink.value = ehConfig.clipboardLink ?? isClipboardLink.value;
    everProfile<bool>(isClipboardLink,
        (bool value) => ehConfig = ehConfig.copyWith(clipboardLink: value));

    commentTrans.value = ehConfig.commentTrans ?? commentTrans.value;
    everProfile<bool>(commentTrans,
        (bool value) => ehConfig = ehConfig.copyWith(commentTrans: value));

    // blurredInRecentTasks
    blurredInRecentTasks.value = storageUtil.getBool(BLURRED_IN_RECENT_TASK);
    everProfile<bool>(blurredInRecentTasks,
        (bool value) => storageUtil.setBool(BLURRED_IN_RECENT_TASK, value));

    // autoLockTimeOut
    autoLockTimeOut.value = ehConfig.autoLockTimeOut ?? autoLockTimeOut.value;
    everProfile<int>(autoLockTimeOut,
        (int value) => ehConfig = ehConfig.copyWith(autoLockTimeOut: value));

    // showPageInterval
    showPageInterval.value =
        ehConfig.showPageInterval ?? showPageInterval.value;
    everProfile<bool>(showPageInterval,
        (bool value) => ehConfig = ehConfig.copyWith(showPageInterval: value));

    // orientation
    orientation.value = EnumToString.fromString(
            ReadOrientation.values, ehConfig.favoritesOrder) ??
        orientation.value;
    everFromEunm(orientation,
        (String value) => ehConfig = ehConfig.copyWith(orientation: value));

    // vibrate
    vibrate.value = ehConfig.vibrate ?? vibrate.value;
    everProfile<bool>(
        vibrate, (bool value) => ehConfig = ehConfig.copyWith(vibrate: value));

    // tagIntroImgLv
    tagIntroImgLv.value = EnumToString.fromString(
            TagIntroImgLv.values, ehConfig.tagIntroImgLv ?? 'nonh') ??
        tagIntroImgLv.value;
    everFromEunm(tagIntroImgLv,
        (String value) => ehConfig = ehConfig.copyWith(tagIntroImgLv: value));

    // viewColumnMode
    viewColumnMode = EnumToString.fromString(
            ViewColumnMode.values, ehConfig.viewColumnMode ?? '') ??
        viewColumnMode;
    everFromEunm(_viewColumnMode,
        (String value) => ehConfig = ehConfig.copyWith(viewColumnMode: value));

    debugCount = ehConfig.debugCount ?? debugCount;
    if (!kDebugMode) {
      debugCount -= 1;
      ehConfig = ehConfig.copyWith(debugCount: debugCount);
    }
    if (debugCount > 0) {
      debugMode = ehConfig.debugMode ?? false;
    } else {
      debugMode = false;
    }
    Global.saveProfile();
    everProfile<bool>(_debugMode, (bool value) {
      ehConfig = ehConfig.copyWith(debugMode: value, debugCount: 3);
      if (value) {
        Logger.level = Level.debug;
        logger.v('Level.debug');
        ehConfig = ehConfig.copyWith(debugCount: 3);
      } else {
        Logger.level = Level.error;
        ehConfig = ehConfig.copyWith(debugCount: 0);
      }
      resetLogLevel();
    });

    // 自动翻页 _autoRead
    autoRead = ehConfig.autoRead ?? autoRead;
    everProfile<bool>(_autoRead,
        (bool value) => ehConfig = ehConfig.copyWith(autoRead: value));

    // 翻页时间间隔 _turnPageInv
    turnPageInv = ehConfig.turnPageInv ?? turnPageInv;
    everProfile<int>(_turnPageInv,
        (int value) => ehConfig = ehConfig.copyWith(turnPageInv: value));

    toplist =
        EnumToString.fromString(ToplistType.values, ehConfig.toplist ?? '') ??
            toplist;
    everFromEunm(_toplist,
        (String value) => ehConfig = ehConfig.copyWith(toplist: value));

    tabletLayout = ehConfig.tabletLayout ?? tabletLayout;
    everProfile<bool>(_tabletLayout,
        (bool value) => ehConfig = ehConfig.copyWith(tabletLayout: value));

    enableTagTranslateCDN =
        ehConfig.enableTagTranslateCDN ?? enableTagTranslateCDN;
    everProfile<bool>(
        _enableTagTranslateCDN,
        (bool value) =>
            ehConfig = ehConfig.copyWith(enableTagTranslateCDN: value));

    // _autoSelectProfile
    autoSelectProfile = ehConfig.autoSelectProfile ?? autoSelectProfile;
    everProfile<bool>(_autoSelectProfile,
        (bool value) => ehConfig = ehConfig.copyWith(autoSelectProfile: value));

    // tapToTurnPageAnimations
    tapToTurnPageAnimations =
        ehConfig.tapToTurnPageAnimations ?? tapToTurnPageAnimations;
    everProfile<bool>(
        _tapToTurnPageAnimations,
        (bool value) =>
            ehConfig = ehConfig.copyWith(tapToTurnPageAnimations: value));

    // downloadOrigImage
    downloadOrigImage = downloadConfig.downloadOrigImage ?? downloadOrigImage;
    everProfile<bool>(_downloadOrigImage, (value) {
      downloadConfig = downloadConfig.copyWith(downloadOrigImage: value);
    });

    // _downloadOrigType
    downloadOrigType = EnumToString.fromString(DownloadOrigImageType.values,
            downloadConfig.downloadOrigImageType ?? '') ??
        (downloadOrigImage
            ? DownloadOrigImageType.askMe
            : DownloadOrigImageType.no);
    everFromEunm(_downloadOrigType, (String value) {
      downloadConfig = downloadConfig.copyWith(downloadOrigImageType: value);
    });

    // _selectProfile
    selectProfile = ehConfig.selectProfile ?? selectProfile;
    everProfile<String>(_selectProfile, (value) {
      ehConfig = ehConfig.copyWith(selectProfile: value);
    });

    // _linkRedirect
    linkRedirect = ehConfig.linkRedirect ?? linkRedirect;
    everProfile<bool>(_linkRedirect, (value) {
      ehConfig = ehConfig.copyWith(linkRedirect: value);
    });

    // fixedHeightOfListItems
    fixedHeightOfListItems =
        ehConfig.fixedHeightOfListItems ?? fixedHeightOfListItems;
    everProfile<bool>(_fixedHeightOfListItems, (value) {
      ehConfig = ehConfig.copyWith(fixedHeightOfListItems: value);
    });

    // tagTranslateDataUpdateMode
    tagTranslateDataUpdateMode = EnumToString.fromString(
            TagTranslateDataUpdateMode.values,
            ehConfig.tagTranslateDataUpdateMode ?? '') ??
        tagTranslateDataUpdateMode;
    everFromEunm(
        _tagTranslateDataUpdateMode,
        (String value) =>
            ehConfig = ehConfig.copyWith(tagTranslateDataUpdateMode: value));

    // tabletLayoutType
    tabletLayoutType = EnumToString.fromString(
            TabletLayout.values, ehConfig.tabletLayoutValue ?? '') ??
        (tabletLayout ? TabletLayout.automatic : TabletLayout.never);
    everFromEunm(
        _tabletLayoutType,
        (String value) =>
            ehConfig = ehConfig.copyWith(tabletLayoutValue: value));

    // _showCommentAvatar
    showCommentAvatar = ehConfig.showCommentAvatar ?? showCommentAvatar;
    everProfile<bool>(_showCommentAvatar, (value) {
      ehConfig = ehConfig.copyWith(showCommentAvatar: value);
    });
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
                    child: Icon(FontAwesomeIcons.checkCircle),
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
      logger.v('to ${EnumToString.convertToString(_result)}');
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
                    child: Icon(FontAwesomeIcons.checkCircle),
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
      logger.v('to ${EnumToString.convertToString(_result)}');
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
      '/${GallerySliverPage().runtimeType.toString()}',
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
        RegExp(r'https?://e[-|x]hentai.org/g/\d+/[0-9a-f]{10}/?');
    final RegExpMatch? _mach = _reg.firstMatch(_text);

    if (_mach == null && (_mach?.group(0)?.isEmpty ?? true)) {
      return;
    }

    if (_currentRouteIsGalleryPage && _lastClipboardLink == _mach?.group(0)) {
      logger.v('剪贴板链接为当前展示的画廊 返回');
      return;
    }

    logger.d('${_mach?.group(0)} ');
    _lastClipboardLink = _mach?.group(0) ?? '';
    if (_lastClipboardLink.isNotEmpty) {
      _showClipboardLinkDialog(
        _lastClipboardLink,
        replace: _replace,
      );
    }
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
