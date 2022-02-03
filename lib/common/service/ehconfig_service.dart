import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  RxInt preloadImage = 5.obs;

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

  @override
  void onInit() {
    super.onInit();

    /// 预载图片数量
    preloadImage.value = downloadConfig.preloadImage ?? 5;
    everProfile<int>(preloadImage, (value) {
      downloadConfig = downloadConfig.copyWith(preloadImage: value);
    });

    // downloadLocatino
    downloadLocatino = downloadConfig.downloadLocation ?? '';
    everProfile<String>(_downloadLocatino, (value) {
      downloadConfig = downloadConfig.copyWith(downloadLocation: value);
    });

    multiDownload = (downloadConfig.multiDownload != null &&
            downloadConfig.multiDownload! > 0)
        ? downloadConfig.multiDownload!
        : 3;
    everProfile<int>(_multiDownload, (value) {
      downloadConfig = downloadConfig.copyWith(multiDownload: value);
    });

    allowMediaScan = downloadConfig.allowMediaScan ?? false;
    everProfile<bool>(_allowMediaScan, (value) {
      downloadConfig = downloadConfig.copyWith(allowMediaScan: value);
    });

    /// 阅读方向
    viewMode.value =
        EnumToString.fromString(ViewMode.values, ehConfig.viewModel) ??
            ViewMode.LeftToRight;
    everFromEunm(viewMode, (String value) {
      ehConfig = ehConfig.copyWith(viewModel: value);
    });

    //
    isSafeMode.value = ehConfig.safeMode ?? false;
    everProfile(isSafeMode, (value) {
      // ehConfig.safeMode = value;
      ehConfig = ehConfig.copyWith(safeMode: value as bool);
      Get.find<TabHomeController>().resetIndex();
    });

    isJpnTitle.value = ehConfig.jpnTitle;
    everProfile(isJpnTitle, (value) {
      ehConfig = ehConfig.copyWith(jpnTitle: value as bool);
      // logger.v('new ehConfig ${ehConfig.toJson()}');
    });

    isTagTranslat = ehConfig.tagTranslat ?? false;
    everProfile(_isTagTranslat,
        (value) => ehConfig = ehConfig.copyWith(tagTranslat: value as bool));

    isGalleryImgBlur.value = ehConfig.galleryImgBlur ?? false;
    everProfile(isGalleryImgBlur,
        (value) => ehConfig = ehConfig.copyWith(galleryImgBlur: value as bool));

    // 站点切换事件
    isSiteEx.value = ehConfig.siteEx ?? false;
    ehDioConfig = isSiteEx.value ? exDioConfig : ehDioConfig;
    everProfile(isSiteEx, (value) {
      logger.d('everProfile isSiteEx');
      ehConfig = ehConfig.copyWith(siteEx: value as bool);
      // ehDioConfig
      //   ..baseUrl = value ? EHConst.EX_BASE_URL : EHConst.EH_BASE_URL
      //   ..maxConnectionsPerHost = value ? 2 : null;
      if (value) {
        // Global.initImageHttpClient(maxConnectionsPerHost: 2);
        ehDioConfig.baseUrl = EHConst.EX_BASE_URL;
        // ..maxConnectionsPerHost = 2;
      } else {
        ehDioConfig.baseUrl = EHConst.EH_BASE_URL;
        // ..maxConnectionsPerHost = null;
      }
    });

    isFavLongTap.value = ehConfig.favLongTap ?? false;
    everProfile(isFavLongTap,
        (value) => ehConfig = ehConfig.copyWith(favLongTap: value as bool));

    catFilter.value = ehConfig.catFilter;
    everProfile(catFilter,
        (value) => ehConfig = ehConfig.copyWith(catFilter: value as int));

    listMode.value =
        EnumToString.fromString(ListModeEnum.values, ehConfig.listMode) ??
            ListModeEnum.list;
    everFromEunm(listMode,
        (String value) => ehConfig = ehConfig.copyWith(listMode: value));

    // maxHistory.value = ehConfig.maxHistory;
    // everProfile(maxHistory,
    //     (value) => ehConfig = ehConfig.copyWith(maxHistory: value as int));

    isSearchBarComp.value = ehConfig.searchBarComp ?? false;
    everProfile(isSearchBarComp,
        (value) => ehConfig = ehConfig.copyWith(searchBarComp: value as bool));

    favoriteOrder.value = EnumToString.fromString(
            FavoriteOrder.values, ehConfig.favoritesOrder) ??
        FavoriteOrder.fav;
    everFromEunm(favoriteOrder,
        (String value) => ehConfig = ehConfig.copyWith(favoritesOrder: value));

    tagTranslatVer.value = ehConfig.tagTranslatVer ?? '';
    everProfile(
        tagTranslatVer,
        (value) =>
            ehConfig = ehConfig.copyWith(tagTranslatVer: value as String));

    lastFavcat.value = ehConfig.lastFavcat ?? '';
    everProfile(lastFavcat,
        (value) => ehConfig = ehConfig.copyWith(lastFavcat: value as String));

    isFavPicker.value = ehConfig.favPicker ?? false;
    everProfile(isFavPicker,
        (value) => ehConfig = ehConfig.copyWith(favPicker: value as bool));

    isPureDarkTheme.value = ehConfig.pureDarkTheme ?? false;
    everProfile<bool>(isPureDarkTheme,
        (bool value) => ehConfig = ehConfig.copyWith(pureDarkTheme: value));

    isClipboardLink.value = ehConfig.clipboardLink ?? false;
    everProfile<bool>(isClipboardLink,
        (bool value) => ehConfig = ehConfig.copyWith(clipboardLink: value));

    commentTrans.value = ehConfig.commentTrans ?? false;
    everProfile<bool>(commentTrans,
        (bool value) => ehConfig = ehConfig.copyWith(commentTrans: value));

    // blurredInRecentTasks
    blurredInRecentTasks.value = storageUtil.getBool(BLURRED_IN_RECENT_TASK);
    everProfile<bool>(blurredInRecentTasks,
        (bool value) => storageUtil.setBool(BLURRED_IN_RECENT_TASK, value));

    // autoLockTimeOut
    autoLockTimeOut.value = ehConfig.autoLockTimeOut ?? -1;
    everProfile<int>(autoLockTimeOut,
        (int value) => ehConfig = ehConfig.copyWith(autoLockTimeOut: value));

    // showPageInterval
    showPageInterval.value = ehConfig.showPageInterval ?? false;
    everProfile<bool>(showPageInterval,
        (bool value) => ehConfig = ehConfig.copyWith(showPageInterval: value));

    // orientation
    orientation.value = EnumToString.fromString(
            ReadOrientation.values, ehConfig.favoritesOrder) ??
        ReadOrientation.system;
    everFromEunm(orientation,
        (String value) => ehConfig = ehConfig.copyWith(orientation: value));

    // vibrate
    vibrate.value = ehConfig.vibrate ?? true;
    everProfile<bool>(
        vibrate, (bool value) => ehConfig = ehConfig.copyWith(vibrate: value));

    // tagIntroImgLv
    tagIntroImgLv.value = EnumToString.fromString(
            TagIntroImgLv.values, ehConfig.tagIntroImgLv ?? 'nonh') ??
        TagIntroImgLv.nonh;
    everFromEunm(tagIntroImgLv,
        (String value) => ehConfig = ehConfig.copyWith(tagIntroImgLv: value));

    // viewColumnMode
    viewColumnMode = EnumToString.fromString(
            ViewColumnMode.values, ehConfig.viewColumnMode ?? '') ??
        ViewColumnMode.single;
    everFromEunm(_viewColumnMode,
        (String value) => ehConfig = ehConfig.copyWith(viewColumnMode: value));

    debugCount = ehConfig.debugCount ?? 3;
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
    autoRead = ehConfig.autoRead ?? false;
    everProfile<bool>(_autoRead,
        (bool value) => ehConfig = ehConfig.copyWith(autoRead: value));

    // 翻页时间间隔 _turnPageInv
    turnPageInv = ehConfig.turnPageInv ?? 3000;
    everProfile<int>(_turnPageInv,
        (int value) => ehConfig = ehConfig.copyWith(turnPageInv: value));

    _toplist.value =
        EnumToString.fromString(ToplistType.values, ehConfig.toplist ?? '') ??
            ToplistType.yesterday;
    everFromEunm(_toplist,
        (String value) => ehConfig = ehConfig.copyWith(toplist: value));

    tabletLayout = ehConfig.tabletLayout ?? true;
    everProfile<bool>(_tabletLayout,
        (bool value) => ehConfig = ehConfig.copyWith(tabletLayout: value));

    enableTagTranslateCDN = ehConfig.enableTagTranslateCDN ?? false;
    everProfile<bool>(
        _enableTagTranslateCDN,
        (bool value) =>
            ehConfig = ehConfig.copyWith(enableTagTranslateCDN: value));

    // _autoSelectProfile
    autoSelectProfile = ehConfig.autoSelectProfile ?? true;
    everProfile<bool>(_autoSelectProfile,
        (bool value) => ehConfig = ehConfig.copyWith(autoSelectProfile: value));

    // tapToTurnPageAnimations
    tapToTurnPageAnimations = ehConfig.tapToTurnPageAnimations ?? true;
    everProfile<bool>(
        _tapToTurnPageAnimations,
        (bool value) =>
            ehConfig = ehConfig.copyWith(tapToTurnPageAnimations: value));

    // downloadOrigImage
    downloadOrigImage = downloadConfig.downloadOrigImage ?? false;
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
    selectProfile = ehConfig.selectProfile ?? '';
    everProfile<String>(_selectProfile, (value) {
      ehConfig = ehConfig.copyWith(selectProfile: value);
    });

    // _linkRedirect
    linkRedirect = ehConfig.linkRedirect ?? false;
    everProfile<bool>(_linkRedirect, (value) {
      ehConfig = ehConfig.copyWith(linkRedirect: value);
    });

    // fixedHeightOfListItems
    fixedHeightOfListItems = ehConfig.fixedHeightOfListItems ?? true;
    everProfile<bool>(_fixedHeightOfListItems, (value) {
      ehConfig = ehConfig.copyWith(fixedHeightOfListItems: value);
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

    final List<String> pageNames = <String>[
      '/${GalleryMainPage().runtimeType.toString()}',
      EHRoutes.galleryPage,
    ];

    logger.d('pageNames $pageNames');
    final bool _curGalleryPage = pageNames.contains(currentRoute);

    final String _text =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    logger.d('Clipboard ' + _text);
    final RegExp _reg =
        RegExp(r'https?://e[-|x]hentai.org/g/\d+/[0-9a-f]{10}/?');
    final RegExpMatch? _mach = _reg.firstMatch(_text);

    if (_mach == null && (_mach?.group(0)?.isEmpty ?? true)) {
      return;
    }

    if (_curGalleryPage && _lastClipboardLink == _mach?.group(0)) {
      logger.v('剪贴板链接为当前展示的画廊 返回');
      return;
    }

    logger.d('${_mach?.group(0)} ');
    _lastClipboardLink = _mach?.group(0) ?? '';
    if (_lastClipboardLink.isNotEmpty) {
      _showClipboardLinkDialog(_lastClipboardLink);
    }
  }

  Future<void> _showClipboardLinkDialog(String url) async {
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
                  NavigatorUtil.goGalleryPage(url: url);
                },
              ),
            ],
          );
        });
  }
}
