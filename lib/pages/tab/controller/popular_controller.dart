import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class PopularViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  final RxBool _isBackgroundRefresh = false.obs;
  bool get isBackgroundRefresh => _isBackgroundRefresh.value;
  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

  @override
  void onInit() {
    super.onInit();

    loadData().then((List<GalleryItem> value) {
      change(value, status: RxStatus.success());
    }).catchError((err) {
      logger.e('$err');
      change(null, status: RxStatus.error(err.toString()));
    }).then((value) {
      isBackgroundRefresh = true;
      reloadData().then((_) => isBackgroundRefresh = false);
    });

    // Future<void>.delayed(const Duration(milliseconds: 400)).then((_) {
    //   isBackgroundRefresh = true;
    //   reloadData().then((_) => isBackgroundRefresh = false);
    // });
  }

  Future<List<GalleryItem>> loadData({bool refresh = false}) async {
    try {
      final Future<Tuple2<List<GalleryItem>, int>> tuple =
          Api.getPopular(refresh: refresh);
      final Future<List<GalleryItem>> gallerItemBeans =
          tuple.then((Tuple2<List<GalleryItem>, int> value) => value.item1);
      return gallerItemBeans;
    } catch (e) {
      logger.e('loadData error: $e');
      rethrow;
    }
  }

  Future<void> reloadData() async {
    //
    final List<GalleryItem> gallerItemBeans = await loadData(refresh: true);
    change(gallerItemBeans);
  }

  Future<void> onRefresh() async {
    change(state, status: RxStatus.success());
    await reloadData();
  }

  Future<void> reLoadDataFirst() async {
    change(state, status: RxStatus.loading());
    onInit();
  }
}
