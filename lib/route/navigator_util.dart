import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/bindings/gallery_page_binding.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_main/view/gallery_page.dart';
import 'package:fehviewer/pages/gallery_view/controller/view_controller.dart';
import 'package:fehviewer/pages/gallery_view/view/view_page.dart';
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
    Get.to(GallerySearchPage(), transition: Transition.cupertino,
        binding: BindingsBuilder(() {
      Get.find<DepthService>().pushAdvSearchCtrl();
      Get.put(
        SearchPageController.fromText(simpleSearch),
        tag: searchPageCtrlDepth,
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

  static void showSearch() {
    Get.to(GallerySearchPage(), transition: Transition.cupertino,
        binding: BindingsBuilder(() {
      Get.find<DepthService>().pushAdvSearchCtrl();
      Get.put(
        SearchPageController(),
        tag: searchPageCtrlDepth,
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
