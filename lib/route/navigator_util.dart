import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/view/search_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigatorUtil {
  /// 转到画廊列表页面
  static void goGalleryList({int cats = 0}) {
    Get.to(const GalleryListTab(),
        binding: BindingsBuilder<GalleryViewController>(() {
      Get.put(GalleryViewController(cats: cats));
    }));
  }

  static void goGalleryListBySearch({
    String simpleSearch,
  }) {
    String _search = simpleSearch;
    if (simpleSearch.contains(':')) {
      final List<String> searArr = simpleSearch.split(':');
      String _end = '';
      if (searArr[0] != 'uploader') {
        _end = '\$';
      }
      _search = '${searArr[0]}:"${searArr[1]}$_end"';
    }

    Get.find<DepthService>().pushSearchPageCtrl();
    Get.to(GallerySearchPage(), transition: Transition.cupertino,
        binding: BindingsBuilder(() {
      Get.lazyPut(
        () => SearchPageController(initSearchText: _search),
        tag: searchPageCtrlDepth,
      );
    }));
  }

  /// 转到画廊页面
  static void goGalleryPage(
      {String url, String tabTag, GalleryItem galleryItem}) {
    Get.find<DepthService>().pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      logger.d('goGalleryPage fromUrl');
      // Get.to(
      //   GalleryMainPage(tabTag: tabTag),
      //   transition: Transition.cupertino,
      //   preventDuplicates: false,
      //   binding: GalleryBinding.fromUrl(url),
      // );
      Get.toNamed(
        EHRoutes.galleryPage,
        preventDuplicates: false,
        arguments: GalleryArg(url: url, tabTag: tabTag),
      );
    } else {
      logger.d('goGalleryPage fromItem tabTag=$tabTag');

      // isLayoutLarge
      //     ? Get.to(
      //         GalleryMainPage(tabTag: tabTag),
      //         id: 2,
      //         transition: Transition.fadeIn,
      //         preventDuplicates: false,
      //         binding: GalleryBinding.fromItem(galleryItem),
      //       )
      //     : Get.to(
      //         GalleryMainPage(tabTag: tabTag),
      //         transition: Transition.cupertino,
      //         preventDuplicates: false,
      //         binding: GalleryBinding.fromItem(galleryItem),
      //       );

      Get.toNamed(
        EHRoutes.galleryPage,
        preventDuplicates: false,
        arguments: GalleryArg(item: galleryItem, tabTag: tabTag),
      );
    }
  }

  static void goGalleryDetailReplace(BuildContext context, {String url}) {
    final DepthService depthService = Get.find();
    depthService.pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      // Get.off(
      //   const GalleryMainPage(),
      //   binding: BindingsBuilder<dynamic>(
      //     () {
      //       Get.put(
      //         GalleryPageController.initUrl(url: url),
      //         tag: '${depthService.pageCtrlDepth}',
      //       );
      //     },
      //   ),
      // );
      Get.offNamed(EHRoutes.galleryPage, arguments: GalleryArg(url: url));
    } else {
      Get.to(
        const GalleryMainPage(),
      );
    }
  }

  // static void goCommitPage() {
  //   Navigator.of(Get.context).push(
  //       CupertinoPageRoute(builder: (BuildContext context) => CommentPage()));
  // }

  /// 打开搜索页面 搜索画廊 搜索关注
  static void showSearch({SearchType searchType, bool fromTabItem = true}) {
    logger.d('fromTabItem $fromTabItem');
    Get.to(GallerySearchPage(),
        transition: fromTabItem ? Transition.fadeIn : Transition.cupertino,
        binding: BindingsBuilder(() {
      Get.find<DepthService>().pushSearchPageCtrl();
      Get.lazyPut(
        () => SearchPageController(searchType: searchType),
        tag: searchPageCtrlDepth,
      );
    }));
  }

  // 转到大图浏览
  static void goGalleryViewPage(int index, String gid) {
    logger.d('goGalleryViewPage $index');
    Get.toNamed(EHRoutes.galleryView, arguments: index);
  }
}
