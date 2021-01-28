import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class RateController extends GetxController {
  RateController({this.pageController});

  double rate;
  final GalleryPageController pageController;

  GalleryItem get _item => pageController.galleryItem;

  @override
  void onInit() {
    super.onInit();
    rate = pageController.galleryItem.rating;
  }

  Future<void> rating() async {
    logger.i('rating $rate');
    logger.d(
        '${pageController.galleryItem.apiuid} ${pageController.galleryItem.apikey}');
    logger.d('${(rate * 2).round()}');
    final Map<String, dynamic> rultMap = await Api.setRating(
      apikey: _item.apikey,
      apiuid: _item.apiuid,
      gid: _item.gid,
      token: _item.token,
      rating: (rate * 2).round(),
    );
    pageController.ratinged(
      ratingUsr: double.parse(rultMap['rating_usr'].toString()),
      ratingAvg: double.parse(rultMap['rating_avg'].toString()),
      ratingCnt: rultMap['rating_cnt'],
      colorRating: rultMap['rating_cls'],
    );
    showToast('Ratting successfully');
  }
}
