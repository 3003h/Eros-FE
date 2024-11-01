import 'package:archive_async/archive_async.dart';
import 'package:collection/collection.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/gallery/comm.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/pages/gallery/gallery_repository.dart';
import 'package:eros_fe/pages/image_view/common.dart';
import 'package:eros_fe/pages/image_view/view/view_page.dart';
import 'package:eros_fe/pages/tab/controller/search_page_controller.dart';
import 'package:eros_fe/pages/tab/view/list/tab_base.dart';
import 'package:eros_fe/route/first_observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

import '../pages/image_view/controller/view_controller.dart';

class NavigatorUtil {
  // 带搜索条件打开搜索
  static Future<void> goSearchPageWithParam({
    required String simpleSearch,
    bool replace = false,
    AdvanceSearch? advanceSearch,
  }) async {
    String _search = simpleSearch;
    if (simpleSearch.contains(':') &&
        EHConst.translateTagType.keys
            .contains(simpleSearch.split(':')[0].trim())) {
      final List<String> searArr = simpleSearch.split(':');
      String _end = '';
      if (searArr[0] != 'uploader') {
        _end = '\$';
      }
      _search = '${searArr[0]}:"${searArr[1]}$_end"';
    }

    Get.find<ControllerTagService>().pushSearchPageCtrl(searchText: _search);
    Get.replace(
      SearchRepository(searchText: _search, advanceSearch: advanceSearch),
    );

    // Get.put(
    //   SearchPageController(),
    //   tag: searchPageCtrlTag,
    //   // permanent: true,
    // );

    Get.lazyPut(
      () => SearchPageController(),
      tag: searchPageCtrlTag,
    );

    if (replace) {
      await Get.offNamed(
        EHRoutes.search,
        preventDuplicates: false,
      );
    } else {
      await Get.toNamed(
        EHRoutes.search,
        id: isLayoutLarge ? 1 : null,
        preventDuplicates: false,
      );
    }

    Get.find<ControllerTagService>().popSearchPageCtrl();
    if ((int.tryParse(searchPageCtrlTag) ?? 0) > 0) {
      logger.d('remove searchPageCtrlTag $searchPageCtrlTag');
      Get.delete<SearchPageController>(tag: searchPageCtrlTag);
    }
  }

  /// 打开搜索页面 指定搜索类型
  static Future<void> goSearchPage({
    SearchType searchType = SearchType.normal,
    bool fromTabItem = true,
  }) async {
    logger.d('fromTabItem $fromTabItem');
    Get.find<ControllerTagService>().pushSearchPageCtrl();

    Get.replace(SearchRepository(searchType: searchType));

    // Get.put(
    //   SearchPageController(),
    //   tag: searchPageCtrlTag,
    //   // permanent: true,
    // );

    Get.lazyPut(
      () => SearchPageController(),
      tag: searchPageCtrlTag,
    );

    await Get.toNamed(
      EHRoutes.search,
      id: isLayoutLarge ? 1 : null,
    );

    Get.find<ControllerTagService>().popSearchPageCtrl();
    if ((int.tryParse(searchPageCtrlTag) ?? 0) > 0) {
      logger.d('remove searchPageCtrlTag $searchPageCtrlTag');
      Get.delete<SearchPageController>(tag: searchPageCtrlTag);
    }
  }

  /// 转到画廊页面
  static Future<void> goGalleryPage({
    String? url,
    dynamic tabTag,
    GalleryProvider? galleryProvider,
    bool replace = false,
    bool forceReplace = false,
  }) async {
    final topSecondRoute =
        SecondNavigatorObserver().history.lastOrNull?.settings.name;
    final topMainRoute =
        MainNavigatorObserver().history.lastOrNull?.settings.name;
    late final String? gid;

    logger.t('topMainRoute $topMainRoute');

    // url跳转方式
    if (url != null && url.isNotEmpty) {
      logger.d('goGalleryPage fromUrl $url');

      final RegExp regGalleryUrl =
          RegExp(r'https?://e[-x]hentai.org/g/([0-9]+)/[0-9a-z]+/?');
      final RegExp regGalleryPageUrl =
          RegExp(r'https?://e[-x]hentai.org/s/[0-9a-z]+/\d+-\d+/?');

      if (regGalleryUrl.hasMatch(url)) {
        final matcher = regGalleryUrl.firstMatch(url);
        gid = matcher?[1];
        // url为画廊链接
        // Get.replace(GalleryRepository(url: url.linkRedirect));
        Get.lazyReplace(
          () => GalleryRepository(url: url.linkRedirect),
          tag: gid,
          fenix: true,
        );
      } else if (regGalleryPageUrl.hasMatch(url)) {
        // url为画廊某一页的链接
        final image = await fetchImageInfoByApi(url.linkRedirect);

        if (image == null) {
          return;
        }

        final ser = image.ser;
        final galleryUrl = '${Api.getBaseUrl()}/g/${image.gid}/${image.token}';
        logger.d('jump to $galleryUrl $ser');

        gid = image.gid ?? '0';

        // Get.replace(GalleryRepository(url: _galleryUrl, jumpSer: ser));
        Get.lazyReplace(
          () => GalleryRepository(url: galleryUrl, jumpSer: ser),
          tag: gid,
          fenix: true,
        );
      }

      // if (GetPlatform.isAndroid) {
      //   final androidInfo = await deviceInfo.androidInfo;
      //   final sdkInt = androidInfo.version.sdkInt;
      //   replace = replace && sdkInt < 31;
      // }

      if (forceReplace || (replace && topMainRoute == EHRoutes.root)) {
        Get.find<ControllerTagService>().pushPageCtrl(gid: gid);
        await Get.offNamed(
          EHRoutes.galleryPage,
          preventDuplicates: false,
        );
        deletePageController();
        Get.find<ControllerTagService>().popPageCtrl();
      } else {
        if (topSecondRoute == EHRoutes.galleryPage) {
          logger.d('topSecondRoute == EHRoutes.galleryPage');
          if (Get.isRegistered<GalleryPageController>(tag: pageCtrlTag) &&
              Get.find<GalleryPageController>(tag: pageCtrlTag).gState.gid ==
                  gid) {
            logger.d('same gallery');
            return;
          }
        }

        Get.find<ControllerTagService>().pushPageCtrl(gid: gid);
        await Get.toNamed(
          EHRoutes.galleryPage,
          id: isLayoutLarge ? 2 : null,
          preventDuplicates: false,
        );
        deletePageController();
        Get.find<ControllerTagService>().popPageCtrl();
      }
    } else {
      // item点击跳转方式
      logger.t('goGalleryPage fromItem tabTag=$tabTag');
      gid = galleryProvider?.gid;

      Global.analytics?.logSelectItem(
        itemListName: 'GalleryList',
        itemListId: tabTag.toString(),
        items: [
          AnalyticsEventItem(
            itemId: gid,
            itemCategory: galleryProvider?.category,
            itemName: galleryProvider?.englishTitle,
            itemVariant: galleryProvider?.japaneseTitle,
            quantity: int.tryParse(galleryProvider?.filecount ?? '0'),
          ),
        ],
      );

      // Get.replace(GalleryRepository(item: galleryProvider, tabTag: tabTag));
      Get.lazyReplace(
        () => GalleryRepository(item: galleryProvider, tabTag: tabTag),
        tag: gid,
        fenix: true,
      );

      // 不同显示模式下的跳转方式
      if (isLayoutLarge) {
        //  大屏幕模式
        // pushPageCtrl 前获取当前的tag
        final curTag = pageCtrlTag;
        Get.find<ControllerTagService>().pushPageCtrl(gid: gid);
        logger.t('topSecondRoute: $topSecondRoute');
        // 如果当前已经打开了画廊页面
        if (topSecondRoute == EHRoutes.galleryPage) {
          logger.d('topSecondRoute == EHRoutes.galleryPage');
          logger.d(
              'curTag $curTag  isReg:${Get.isRegistered<GalleryPageController>(tag: curTag)}');
          if (Get.isRegistered<GalleryPageController>(tag: curTag) &&
              Get.find<GalleryPageController>(tag: curTag).gState.gid == gid) {
            logger.d('same gallery');
            Get.find<ControllerTagService>().popPageCtrl();
            return;
          } else {
            await Get.offNamed(
              EHRoutes.galleryPage,
              id: 2,
              preventDuplicates: true,
            );
          }
        } else if (topSecondRoute != EHRoutes.empty) {
          logger.d('Get.offNamed');
          await Get.offNamed(
            EHRoutes.galleryPage,
            id: 2,
            preventDuplicates: true,
          );
        } else {
          await Get.toNamed(
            EHRoutes.galleryPage,
            id: 2,
            preventDuplicates: true,
          );
        }
      } else {
        // 一般模式
        Get.find<ControllerTagService>().pushPageCtrl(gid: gid);
        await Get.toNamed(
          EHRoutes.galleryPage,
          preventDuplicates: false,
        );
        deletePageController();
        Get.find<ControllerTagService>().popPageCtrl();
      }
    }
    // deletePageController();
  }

  // 转到大图浏览
  static Future<void> goGalleryViewPage(int index, String gid) async {
    // logger.d('goGalleryViewPage $index');
    // 命名路由方式
    await Get.toNamed(EHRoutes.galleryViewExt,
        arguments: ViewRepository(
          index: index,
          loadType: LoadFrom.gallery,
          gid: gid,
        ));
    Get.delete<ViewExtController>();
  }

  // 打开已下载任务阅读
  static Future<void> goGalleryViewPageFile(
      int index, List<String> pics, String gid) async {
    // 命名路由方式
    await Get.toNamed(EHRoutes.galleryViewExt,
        arguments: ViewRepository(
          index: index,
          files: pics,
          loadType: LoadFrom.download,
          gid: gid,
        ));
    Get.delete<ViewExtController>();
  }

  // 打开归档压缩包阅读
  static Future<void> goGalleryViewPageArchiver(
      int index, AsyncArchive asyncArchive, String gid) async {
    // 命名路由方式
    await Get.toNamed(EHRoutes.galleryViewExt,
        arguments: ViewRepository(
          index: index,
          asyncArchives: asyncArchive.files,
          loadType: LoadFrom.archiver,
          gid: gid,
        ));
    Get.delete<ViewExtController>();
  }

  static Future<void> goItemWidthSettingPage() async {
    final topFirstRoute =
        FirstNavigatorObserver().history.lastOrNull?.settings.name;

    if (topFirstRoute == EHRoutes.itemWidthSetting) {
      return;
    }

    Get.toNamed(
      EHRoutes.itemWidthSetting,
      id: isLayoutLarge ? 1 : null,
    );
  }
}
