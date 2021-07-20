import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:get/get.dart';
import '../view/view_ext_page.dart';

enum LoadType {
  network,
  file,
}

class ViewExtState {
  /// 初始化操作
  ViewExtState() {
    // 设置加载类型
    if (Get.arguments is ViewRepository) {
      final ViewRepository vr = Get.arguments;
      loadType = vr.loadType;
      if (loadType == LoadType.file) {
        if (vr.files != null) {
          imagePathList = vr.files!;
        }
      } else {
        _galleryPageController = Get.find(tag: pageCtrlDepth);
      }

      currentItemIndex = vr.index;
    }
  }

  late final GalleryPageController _galleryPageController;

  ///
  LoadType loadType = LoadType.network;

  /// 当前的index
  int currentItemIndex = 0;

  /// imagePathList
  List<String> imagePathList = <String>[];

  int get filecount {
    if (loadType == LoadType.file) {
      return imagePathList.length;
    } else {
      return int.parse(_galleryPageController.galleryItem.filecount ?? '0');
    }
  }

  ///
  int get pageCount {
    return filecount;
  }
}
