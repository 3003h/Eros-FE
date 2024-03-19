import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

class RateController extends GetxController {
  RateController();

  late double rate;

  late GalleryPageController pageController;
  GalleryPageState get _pageState => pageController.gState;
  GalleryProvider? get _item => _pageState.galleryProvider;

  @override
  void onInit() {
    super.onInit();
    pageController = Get.find(tag: pageCtrlTag);
    rate = _item?.rating ?? 0;
  }

  Future<void> rating() async {
    if (_item == null) {
      return;
    }

    logger.t('rating $rate');
    logger.t('${_item?.apiuid} ${_item?.apikey}');
    logger.t('${(rate * 2).round()}');
    final Map<String, dynamic> rultMap = await Api.setRating(
      apikey: _item!.apikey ?? '',
      apiuid: _item!.apiuid ?? '',
      gid: _item!.gid ?? '0',
      token: _item!.token ?? '',
      rating: (rate * 2).round(),
    );
    pageController.afterRating(
      ratingUsr: double.parse(rultMap['rating_usr'].toString()),
      ratingAvg: double.parse(rultMap['rating_avg'].toString()),
      ratingCnt: rultMap['rating_cnt'] as int,
      colorRating: rultMap['rating_cls'] as String,
    );
    showToast('Ratting successfully');
  }
}
