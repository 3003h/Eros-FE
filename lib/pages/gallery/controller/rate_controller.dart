import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class RateController extends GetxController {
  RateController();

  late double rate;

  GalleryPageController get pageController => Get.find(tag: pageCtrlDepth);

  GalleryItem? get _item => pageController.galleryItem;

  @override
  void onInit() {
    super.onInit();
    rate = pageController.galleryItem?.rating ?? 0;
  }

  Future<void> rating() async {
    if (_item == null) {
      return;
    }

    logger.d('rating $rate');
    logger.d(
        '${pageController.galleryItem?.apiuid} ${pageController.galleryItem?.apikey}');
    logger.d('${(rate * 2).round()}');
    final Map<String, dynamic> rultMap = await Api.setRating(
      apikey: _item!.apikey ?? '',
      apiuid: _item!.apiuid ?? '',
      gid: _item!.gid ?? '0',
      token: _item!.token ?? '',
      rating: (rate * 2).round(),
    );
    pageController.ratinged(
      ratingUsr: double.parse(rultMap['rating_usr'].toString()),
      ratingAvg: double.parse(rultMap['rating_avg'].toString()),
      ratingCnt: rultMap['rating_cnt'] as int,
      colorRating: rultMap['rating_cls'] as String,
    );
    showToast('Ratting successfully');
  }
}
