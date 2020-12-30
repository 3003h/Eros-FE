import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class RateController extends GetxController {
  double rate;
  GalleryPageController _pageController;
  GalleryItem get _item => _pageController.galleryItem;

  @override
  void onInit() {
    super.onInit();
    _pageController = Get.find(tag: pageCtrlDepth);
    rate = _pageController.galleryItem.rating;
  }

  Future<void> rating() async {
    logger.i('rating $rate');
    logger.d(
        '${_pageController.galleryItem.apiuid} ${_pageController.galleryItem.apikey}');
    logger.d('${(rate * 2).round()}');
    await Api.setRating(
      apikey: _item.apikey,
      apiuid: _item.apiuid,
      gid: _item.gid,
      token: _item.token,
      rating: (rate * 2).round(),
    );
    _pageController.ratinged();
    showToast('Ratting successfully');
  }
}
