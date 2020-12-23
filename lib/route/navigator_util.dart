import 'package:fehviewer/common/exts.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/galleryComment.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_main/view/comment_page.dart';
import 'package:fehviewer/pages/gallery_main/view/gallery_page.dart';
import 'package:fehviewer/pages/gallery_view/controller/view_controller.dart';
import 'package:fehviewer/pages/gallery_view/view/gallery_view_page.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
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
    Get.to(GallerySearchPage(searchText: simpleSearch));
  }

  /// 转到画廊页面
  static void goGalleryPage(
      {String url, String tabIndex, GalleryItem galleryItem}) {
    final DepthService depthService = Get.find();
    depthService.pushPageCtrl();

    if (url != null && url.isNotEmpty) {
      final String gid = url.gid;
      // TODO(honjow): 通过链接直接打开画廊的情况
      // ignore: always_specify_types
      Get.to(
        const GalleryPage(),
        transition: Transition.cupertino,
        preventDuplicates: false,
        binding: BindingsBuilder(() {
          Get.put(GalleryPageController.initUrl(url: url),
              tag: '${depthService.pageCtrlDepth}');
        }),
      );
    } else {
      Get.to(
        const GalleryPage(),
        transition: Transition.cupertino,
        binding: BindingsBuilder<GalleryPageController>(
          () {
            Get.put(
              GalleryPageController.fromItem(
                galleryItem: galleryItem,
                tabIndex: tabIndex,
              ),
              tag: '${depthService.pageCtrlDepth}',
            );
          },
        ),
      );
    }
  }

  static void goGalleryDetailReplace(BuildContext context, {String url}) {
    if (url != null && url.isNotEmpty) {
      Get.off(GalleryPage(), binding: BindingsBuilder(() {
        Get.put(GalleryPageController.initUrl(url: url));
      }));
    } else {
      Get.to(GalleryPage());
    }
  }

  static void showSearch() {
    Get.to(const GallerySearchPage());
  }

  /// 转到画廊评论页面
  static void goGalleryDetailComment(List<GalleryComment> comments) {
    Get.to(CommentPage(galleryComments: comments));
  }

  // 转到大图浏览
  static void goGalleryViewPage(int index, String gid) {
    logger.d('goGalleryViewPage $index');
    Get.to(
      GalleryViewPage(),
      binding: BindingsBuilder(() {
        // Get.lazyPut(() => ViewController(index));
        Get.put(ViewController(index));
      }),
    );
  }
}
