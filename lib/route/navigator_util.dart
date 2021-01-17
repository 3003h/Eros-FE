import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/bindings/gallery_page_binding.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_page.dart';
import 'package:fehviewer/pages/tab/view/search_page.dart';
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
        fenix: true,
      );
    }));
  }

  /// 转到画廊页面
  static void goGalleryPage(
      {String url, String tabIndex, GalleryItem galleryItem}) {
    Get.find<DepthService>().pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      logger.d('goGalleryPage fromUrl');
      Get.to(
        const GalleryMainPage(),
        transition: Transition.cupertino,
        preventDuplicates: false,
        binding: GalleryBinding.fromUrl(url),
      );
    } else {
      logger.d('goGalleryPage fromItem');
      Get.to(
        const GalleryMainPage(),
        transition: Transition.cupertino,
        preventDuplicates: false,
        binding: GalleryBinding.fromItem(tabIndex, galleryItem),
      );
    }
  }

  static void goGalleryDetailReplace(BuildContext context, {String url}) {
    final DepthService depthService = Get.find();
    depthService.pushPageCtrl();
    if (url != null && url.isNotEmpty) {
      Get.off(
        const GalleryMainPage(),
        binding: BindingsBuilder<dynamic>(
          () {
            Get.put(
              GalleryPageController.initUrl(url: url),
              tag: '${depthService.pageCtrlDepth}',
            );
          },
        ),
      );
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
        fenix: true,
      );
    }));
  }

  // 转到大图浏览
  static void goGalleryViewPage(int index, String gid) {
    logger.d('goGalleryViewPage $index');
    Get.to(
      const GalleryViewPage(),
      transition: Transition.cupertino,
      binding: BindingsBuilder<dynamic>(() {
        // Get.lazyPut(() => ViewController(index));
        Get.put(ViewController(index));
      }),
    );
  }
}
