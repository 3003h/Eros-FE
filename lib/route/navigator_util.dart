import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view_ext/common.dart';
import 'package:fehviewer/pages/image_view_ext/view/view_ext_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/view/search_page_new.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    /*Get.to(
      // () => GallerySearchPage(),
      () => GallerySearchPageNew(),
      transition: Transition.cupertino,
      binding: BindingsBuilder(() {
        logger.d('goGalleryListBySearch BindingsBuilder');
        Get.lazyPut(
          () => SearchPageController(initSearchText: _search),
          tag: searchPageCtrlDepth,
        );
      }),
    );*/

    await Get.toNamed(
      EHRoutes.search,
      arguments: _search,
      preventDuplicates: false,
    );

    Get.find<DepthService>().popSearchPageCtrl();
  }

  /// 转到画廊页面
  static Future<void> goGalleryPage({
    String? url,
    String? tabTag,
    GalleryItem? galleryItem,
  }) async {
    Get.find<DepthService>().pushPageCtrl();

    // url跳转方式
    if (url != null && url.isNotEmpty) {
      logger.d('goGalleryPage fromUrl');
      // 命名路由方式
      await Get.toNamed(
        EHRoutes.galleryPage,
        arguments: GalleryRepository(url: url),
        preventDuplicates: false,
      );

      // Get.to(
      //   () => GalleryMainPage(),
      //   binding: GalleryBinding(
      //     galleryRepository: GalleryRepository(url: url, tabTag: tabTag),
      //   ),
      //   preventDuplicates: false,
      //   // arguments: GalleryRepository(url: url, tabTag: tabTag),
      // );
    } else {
      // item点击跳转方式
      logger.v('goGalleryPage fromItem tabTag=$tabTag');

      //命名路由
      await Get.toNamed(
        EHRoutes.galleryPage,
        arguments: GalleryRepository(item: galleryItem, tabTag: tabTag),
        preventDuplicates: false,
      );

      // 普通路由

      // Get.to(
      //   () => GalleryMainPage(
      //     galleryRepository:
      //         GalleryRepository(item: galleryItem, tabTag: tabTag),
      //   ),
      //   binding: GalleryBinding(
      //     galleryRepository:
      //         GalleryRepository(item: galleryItem, tabTag: tabTag),
      //   ),
      //   preventDuplicates: false,
      //   // arguments: GalleryRepository(item: galleryItem, tabTag: tabTag),
      // );
    }
    Get.find<DepthService>().popPageCtrl();
  }

  // 跳转画廊页并替换当前路由
  static Future<void> goGalleryDetailReplace(
    BuildContext context, {
    String? url,
  }) async {
    final DepthService depthService = Get.find();
    depthService.pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      // 命名路由方式
      await Get.offNamed(EHRoutes.galleryPage,
          arguments: GalleryRepository(url: url));

      // 普通方式
      // Get.off(
      //   () => GalleryMainPage(
      //     galleryRepository: GalleryRepository(url: url),
      //   ),
      //   binding: GalleryBinding(
      //     galleryRepository: GalleryRepository(url: url),
      //   ),
      //   preventDuplicates: false,
      //   // arguments: GalleryRepository(url: url),
      // );
    } else {
      logger5.wtf('为什么会到这?');
      // Get.off(
      //   () => GalleryMainPage(),
      //   preventDuplicates: false,
      // );
    }

    depthService.popPageCtrl();
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
          ));
    }
  }

  static Future<void> goGalleryViewPageFile(
      int index, List<String> pics) async {
    // 命名路由方式
    await Get.toNamed(EHRoutes.galleryViewExt,
        arguments: ViewRepository(
          index: index,
          files: pics,
          loadType: LoadType.file,
        ));
  }
}
