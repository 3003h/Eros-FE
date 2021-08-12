import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/pages/gallery/controller/rate_controller.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view_ext/common.dart';
import 'package:fehviewer/pages/image_view_ext/view/view_ext_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/view/search_page_new.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NavigatorUtil {
  /// 转到画廊列表页面
  static Future<void> goGalleryList({int cats = 0}) async {
    await Get.to(() => const GalleryListTab(),
        binding: BindingsBuilder<GalleryViewController>(() {
      Get.put(GalleryViewController(cats: cats));
    }));
  }

  // 带搜索条件打开搜索
  static Future<void> goGalleryListBySearch({
    required String simpleSearch,
    bool replace = false,
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

    Get.find<DepthService>().pushSearchPageCtrl();

    if (replace) {
      await Get.offNamed(
        EHRoutes.search,
        arguments: _search,
        preventDuplicates: false,
      );
    } else {
      await Get.toNamed(
        EHRoutes.search,
        arguments: _search,
        preventDuplicates: false,
      );
    }

    Get.find<DepthService>().popSearchPageCtrl();
  }

  /// 转到画廊页面
  static Future<void> goGalleryPage({
    String? url,
    dynamic tabTag,
    GalleryItem? galleryItem,
    bool replace = false,
  }) async {
    if (!isLayoutLarge) {
      Get.find<DepthService>().pushPageCtrl();
    }

    // url跳转方式
    if (url != null && url.isNotEmpty) {
      logger.v('goGalleryPage fromUrl $url');

      final RegExp regGalleryUrl =
          RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
      final RegExp regGalleryPageUrl =
          RegExp(r'https://e[-x]hentai.org/s/[0-9a-z]+/\d+-\d+');

      if (regGalleryUrl.hasMatch(url)) {
        // 命名路由方式
        if (replace) {
          await Get.offNamed(
            EHRoutes.galleryPage,
            arguments: GalleryRepository(url: url),
            preventDuplicates: false,
          );
        } else {
          await Get.toNamed(
            EHRoutes.galleryPage,
            arguments: GalleryRepository(url: url),
            preventDuplicates: false,
          );
        }
      } else if (regGalleryPageUrl.hasMatch(url)) {
        // url为画廊某一页的链接
        final _image = await Api.fetchImageInfo(url);
        final ser = _image.ser;
        final _galleryUrl =
            '${Api.getBaseUrl()}/g/${_image.gid}/${_image.token}';
        logger.d('jump to $_galleryUrl $ser');

        if (replace) {
          await Get.offNamed(
            EHRoutes.galleryPage,
            arguments: GalleryRepository(url: _galleryUrl, jumpSer: ser),
            preventDuplicates: false,
          );
        } else {
          await Get.toNamed(
            EHRoutes.galleryPage,
            arguments: GalleryRepository(url: _galleryUrl, jumpSer: ser),
            preventDuplicates: false,
          );
        }
      }
    } else {
      // item点击跳转方式
      logger.v('goGalleryPage fromItem tabTag=$tabTag');

      logger.d('put GalleryRepository $pageCtrlDepth');
      Get.put(GalleryRepository(item: galleryItem, tabTag: tabTag),
          tag: pageCtrlDepth);

      //命名路由
      if (isLayoutLarge && Get.currentRoute == EHRoutes.home) {
        if (int.parse(pageCtrlDepth) > 0) {
          logger.d('2 back pageCtrlDepth:$pageCtrlDepth');
          // Get.back(id: 2);
          await Get.delete<GalleryRepository>(tag: pageCtrlDepth);
          Get.put(GalleryRepository(item: galleryItem, tabTag: tabTag),
              tag: pageCtrlDepth);
        }

        await Get.offNamed(
          EHRoutes.galleryPage,
          id: 2,
          preventDuplicates: false,
          // arguments: GalleryRepository(item: galleryItem, tabTag: tabTag),
        );
        // Get.delete<GalleryRepository>(tag: pageCtrlDepth);
      } else {
        await Get.toNamed(
          EHRoutes.galleryPage,
          preventDuplicates: false,
          // arguments: GalleryRepository(item: galleryItem, tabTag: tabTag),
        );
      }
    }

    // 为了保证能正常关闭
    deletePageController();

    if (!isLayoutLarge) {
      Get.find<DepthService>().popPageCtrl();
    }
  }

  /// 打开搜索页面 指定搜索类型
  static Future<void> showSearch({
    SearchType searchType = SearchType.normal,
    bool fromTabItem = true,
  }) async {
    logger.d('fromTabItem $fromTabItem');
    Get.find<DepthService>().pushSearchPageCtrl();

    await Get.to(
      // () => GallerySearchPage(),
      () => GallerySearchPageNew(),
      transition: fromTabItem ? Transition.fadeIn : Transition.cupertino,
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SearchPageController(searchType: searchType),
          tag: searchPageCtrlDepth,
        );
      }),
    );

    Get.find<DepthService>().popSearchPageCtrl();
  }

  // 转到大图浏览
  static Future<void> goGalleryViewPage(int index, String gid) async {
    // logger.d('goGalleryViewPage $index');
    // 命名路由方式
    if (!kDebugMode && false) {
      await Get.toNamed(EHRoutes.galleryView, arguments: index);
    } else {
      await Get.toNamed(EHRoutes.galleryViewExt,
          arguments: ViewRepository(
            index: index,
            loadType: LoadType.network,
            gid: gid,
          ));
    }
  }

  static Future<void> goGalleryViewPageFile(
      int index, List<String> pics, String gid) async {
    // 命名路由方式
    await Get.toNamed(EHRoutes.galleryViewExt,
        arguments: ViewRepository(
          index: index,
          files: pics,
          loadType: LoadType.file,
          gid: gid,
        ));
  }

  static void deletePageController() {
    logger.d('deletePageController');
    // 为了保证能正常关闭
    if (Get.isRegistered<RateController>(tag: pageCtrlDepth))
      Get.delete<RateController>(tag: pageCtrlDepth);
    if (Get.isRegistered<TorrentController>(tag: pageCtrlDepth))
      Get.delete<TorrentController>(tag: pageCtrlDepth);
    if (Get.isRegistered<ArchiverController>(tag: pageCtrlDepth))
      Get.delete<ArchiverController>(tag: pageCtrlDepth);
    if (Get.isRegistered<CommentController>(tag: pageCtrlDepth))
      Get.delete<CommentController>(tag: pageCtrlDepth);
    if (Get.isRegistered<TagInfoController>(tag: pageCtrlDepth))
      Get.delete<TagInfoController>(tag: pageCtrlDepth);
  }
}
