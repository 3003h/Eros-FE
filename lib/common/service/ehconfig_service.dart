import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/base_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/storages.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'locale_service.dart';

class EhConfigService extends ProfileService {
  RxBool isJpnTitle = false.obs;
  // RxBool isTagTranslat = false.obs;
  RxBool isGalleryImgBlur = false.obs;
  RxBool isSiteEx = false.obs;
  RxBool isFavLongTap = false.obs;
  RxInt catFilter = 0.obs;
  Rx<ListModeEnum> listMode = ListModeEnum.list.obs;
  RxInt maxHistory = 100.obs;
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

  final LocaleService localeService = Get.find();

  final _isTagTranslat = false.obs;
  bool get isTagTranslat {
    return localeService.isLanguageCodeZh && _isTagTranslat.value;
  }

  set isTagTranslat(val) => _isTagTranslat.value = val;

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

  final _debugMode = false.obs;
  get debugMode => _debugMode.value;
  set debugMode(val) => _debugMode.value = val;

  final _downloadLocatino = ''.obs;
  get downloadLocatino => _downloadLocatino.value;
  set downloadLocatino(val) => _downloadLocatino.value = val;

  @override
  void onInit() {
    super.onInit();

    /// 预载图片数量
    preloadImage.value = downloadConfig.preloadImage ?? 5;
    everProfile<int>(preloadImage, (value) {
      // downloadConfig.preloadImage = value;
      downloadConfig = downloadConfig.copyWith(preloadImage: value);
    });

    // downloadLocatino
    downloadLocatino = downloadConfig.downloadLocatino ?? '';
    everProfile<String>(_downloadLocatino, (value) {
      downloadConfig = downloadConfig.copyWith(downloadLocatino: value);
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

    isSiteEx.value = ehConfig.siteEx ?? false;
    everProfile(isSiteEx,
        (value) => ehConfig = ehConfig.copyWith(siteEx: value as bool));

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

    maxHistory.value = ehConfig.maxHistory;
    everProfile(maxHistory,
        (value) => ehConfig = ehConfig.copyWith(maxHistory: value as int));

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

    //
    debugMode = ehConfig.debugMode ?? false;
    everProfile<bool>(_debugMode, (bool value) {
      ehConfig = ehConfig.copyWith(debugMode: value);
      if (value) {
        Logger.level = Level.debug;
        logger.v('Level.debug');
      } else {
        Logger.level = Level.error;
      }
      resetLogLevel();
    });
  }

  /// 收藏排序
  Future<FavoriteOrder?> showFavOrder(BuildContext context) async {
    List<Widget> _getOrderList(BuildContext context) {
      final Map<FavoriteOrder, String> _orderMap = <FavoriteOrder, String>{
        FavoriteOrder.posted: S.of(context).favorites_order_Use_posted,
        FavoriteOrder.fav: S.of(context).favorites_order_Use_favorited,
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(CupertinoIcons.checkmark),
                  ),
                Text(_orderMap[element] ?? ''),
              ],
            ));
      }).toList());
    }

    final FavoriteOrder? _result = await showCupertinoModalPopup<FavoriteOrder>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(S.of(context).favorites_order),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
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
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoDialogAction(
                child: Text(S.of(context).ok),
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
