import 'package:fehviewer/models/galleryComment.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_detail/comment_page.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_main/gallery_page.dart';
import 'package:fehviewer/pages/gallery_view/controller/view_controller.dart';
import 'package:fehviewer/pages/gallery_view/gallery_view_page.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
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
    if (url != null && url.isNotEmpty) {
      // TODO(honjow): 通过链接直接打开画廊的情况
      // ignore: always_specify_types
      Get.to(GalleryPage(), binding: BindingsBuilder(() {
        Get.lazyPut(() => GalleryItemController.initUrl(url: url));
      }));
    } else {
      Get.to(
        GalleryPage(),
        transition: Transition.cupertino,
        binding: BindingsBuilder<GalleryPageController>(
          () {
            // 创建GalleryPageController依赖 不能保留 在退出页面后销毁
            Get.put(
              GalleryPageController.fromItem(
                galleryItem: galleryItem,
                tabIndex: tabIndex,
              ),
            );
          },
        ),
      );
    }
  }

  static void goGalleryDetailReplace(BuildContext context, {String url}) {
    if (url != null && url.isNotEmpty) {
      Get.off(GalleryPage(), binding: BindingsBuilder(() {
        Get.create(() => GalleryItemController.initUrl(url: url));
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
  static void goGalleryViewPage(int index) {
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
