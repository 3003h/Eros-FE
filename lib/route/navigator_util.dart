import 'package:archive_async/archive_async.dart';
import 'package:collection/collection.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/comm.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/gallery_repository.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/route/second_observer.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

import '../pages/image_view/controller/view_controller.dart';
import 'main_observer.dart';

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
        SearchRepository(searchText: _search, advanceSearch: advanceSearch));

    Get.put(
      SearchPageController(),
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
  }

  /// 打开搜索页面 指定搜索类型
  static Future<void> goSearchPage({
    SearchType searchType = SearchType.normal,
    bool fromTabItem = true,
  }) async {
    logger.d('fromTabItem $fromTabItem');
    Get.find<ControllerTagService>().pushSearchPageCtrl();

    Get.replace(SearchRepository(searchType: searchType));

    Get.put(
      SearchPageController(),
      tag: searchPageCtrlTag,
    );

    await Get.toNamed(
      EHRoutes.search,
      id: isLayoutLarge ? 1 : null,
    );

    Get.find<ControllerTagService>().popSearchPageCtrl();
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
    late final String? _gid;

    logger.v('topMainRoute $topMainRoute');

    // url跳转方式
    if (url != null && url.isNotEmpty) {
      logger.d('goGalleryPage fromUrl $url');

      final RegExp regGalleryUrl =
          RegExp(r'https?://e[-x]hentai.org/g/([0-9]+)/[0-9a-z]+/?');
      final RegExp regGalleryPageUrl =
          RegExp(r'https?://e[-x]hentai.org/s/[0-9a-z]+/\d+-\d+');

      if (regGalleryUrl.hasMatch(url)) {
        // url为画廊链接
        Get.replace(GalleryRepository(url: url.linkRedirect));
        final matcher = regGalleryUrl.firstMatch(url);
        _gid = matcher?[1];
      } else if (regGalleryPageUrl.hasMatch(url)) {
        // url为画廊某一页的链接
        final _image = await fetchImageInfo(url.linkRedirect);

        if (_image == null) {
          return;
        }

        final ser = _image.ser;
        final _galleryUrl =
            '${Api.getBaseUrl()}/g/${_image.gid}/${_image.token}';
        logger.d('jump to $_galleryUrl $ser');

        _gid = _image.gid ?? '0';

        Get.replace(GalleryRepository(url: _galleryUrl, jumpSer: ser));
      }

      // if (GetPlatform.isAndroid) {
      //   final androidInfo = await deviceInfo.androidInfo;
      //   final sdkInt = androidInfo.version.sdkInt;
      //   replace = replace && sdkInt < 31;
      // }

      if (forceReplace || (replace && topMainRoute == EHRoutes.root)) {
        Get.find<ControllerTagService>().pushPageCtrl(gid: _gid);
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
                  _gid) {
            logger.d('same gallery');
            return;
          }
        }

        Get.find<ControllerTagService>().pushPageCtrl(gid: _gid);
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
      logger.v('goGalleryPage fromItem tabTag=$tabTag');
      _gid = galleryProvider?.gid;

      Get.replace(GalleryRepository(item: galleryProvider, tabTag: tabTag));

      //命名路由
      if (isLayoutLarge) {
        Get.find<ControllerTagService>().pushPageCtrl(gid: _gid);

        logger.v('topSecondRoute: $topSecondRoute');
        if (topSecondRoute == EHRoutes.galleryPage) {
          logger.d('topSecondRoute == EHRoutes.galleryPage');
          final curTag = pageCtrlTag;
          logger.v(
              'curTag $curTag  isReg:${Get.isRegistered<GalleryPageController>(tag: curTag)}');
          if (Get.isRegistered<GalleryPageController>(tag: curTag) &&
              Get.find<GalleryPageController>(tag: curTag).gState.gid == _gid) {
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
        Get.find<ControllerTagService>().pushPageCtrl(gid: _gid);
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
}
