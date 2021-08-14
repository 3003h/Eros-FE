import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/comm.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/view/search_page.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
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
    Get.replace(SearchRepository(searchText: _search));

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

    Get.find<DepthService>().popSearchPageCtrl();
  }

  /// 打开搜索页面 指定搜索类型
  static Future<void> showSearch({
    SearchType searchType = SearchType.normal,
    bool fromTabItem = true,
  }) async {
    logger.d('fromTabItem $fromTabItem');
    Get.find<DepthService>().pushSearchPageCtrl();

    Get.replace(SearchRepository(searchType: searchType));

    await Get.to(
      () => GallerySearchPage(),
      id: isLayoutLarge ? 1 : null,
      transition: fromTabItem ? Transition.fadeIn : Transition.cupertino,
    );

    Get.find<DepthService>().popSearchPageCtrl();
  }

  /// 转到画廊页面
  static Future<void> goGalleryPage({
    String? url,
    dynamic tabTag,
    GalleryItem? galleryItem,
    bool replace = false,
  }) async {
    // url跳转方式
    if (url != null && url.isNotEmpty) {
      Get.find<DepthService>().pushPageCtrl();
      logger.v('goGalleryPage fromUrl $url');

      final RegExp regGalleryUrl =
          RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
      final RegExp regGalleryPageUrl =
          RegExp(r'https://e[-x]hentai.org/s/[0-9a-z]+/\d+-\d+');

      if (regGalleryUrl.hasMatch(url)) {
        // url为画廊链接
        Get.replace(GalleryRepository(url: url));
        // 命名路由方式
        if (replace) {
          await Get.offNamed(
            EHRoutes.galleryPage,
            preventDuplicates: false,
          );
        } else {
          await Get.toNamed(
            EHRoutes.galleryPage,
            id: isLayoutLarge ? 2 : null,
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

        Get.replace(GalleryRepository(url: _galleryUrl, jumpSer: ser));

        if (replace) {
          await Get.offNamed(
            EHRoutes.galleryPage,
            preventDuplicates: false,
          );
        } else {
          await Get.toNamed(
            EHRoutes.galleryPage,
            id: isLayoutLarge ? 2 : null,
            preventDuplicates: false,
          );
        }
      }
      deletePageController();
      Get.find<DepthService>().popPageCtrl();
    } else {
      // item点击跳转方式
      logger.v('goGalleryPage fromItem tabTag=$tabTag');

      // logger.v('put GalleryRepository $pageCtrlDepth');

      Get.replace(GalleryRepository(item: galleryItem, tabTag: tabTag));

      //命名路由
      if (isLayoutLarge && Get.currentRoute == EHRoutes.home) {
        Get.find<DepthService>().pushPageCtrl();
        await Get.offNamed(
          EHRoutes.galleryPage,
          id: 2,
          preventDuplicates: false,
        );
        // deletePageController();
      } else {
        Get.find<DepthService>().pushPageCtrl();
        await Get.toNamed(
          EHRoutes.galleryPage,
          preventDuplicates: false,
        );
        deletePageController();
        Get.find<DepthService>().popPageCtrl();
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
          loadType: LoadType.network,
          gid: gid,
        ));
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
}
