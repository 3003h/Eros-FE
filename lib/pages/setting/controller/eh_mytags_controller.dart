import 'package:fehviewer/network/request.dart';
import 'package:get/get.dart';

import '../../../common/service/ehconfig_service.dart';
import '../../../fehviewer.dart';

const kEhMyTags = EhMytags(tagsets: []);

class EhMyTagsController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool val) => _isLoading.value = val;

  final _ehMyTags = kEhMyTags.obs;
  EhMytags get ehMyTags => _ehMyTags.value;
  set ehMyTags(EhMytags val) => _ehMyTags.value = val;

  final EhConfigService ehConfigService = Get.find();

  Future<EhMytags?> loadData({bool refresh = false}) async {
    try {
      final mytags = await getMyTags(
        refresh: refresh || Global.forceRefreshUconfig,
        selectTagset: '',
      );
      isLoading = false;

      if (mytags != null) {
        Global.forceRefreshUconfig = false;
        ehMyTags = mytags;
        return mytags;
      }
    } catch (e) {
      rethrow;
    } finally {
      // isLoading = false;
    }
  }

  Future<void> reloadData() async {
    await loadData(refresh: true);
  }

  void deleteTagset() {}

  void crtNewTagset() {}
}
