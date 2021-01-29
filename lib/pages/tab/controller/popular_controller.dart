import 'package:dio/dio.dart';
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

  final CancelToken _cancelToken = CancelToken();

  @override
  void onInit() {
    super.onInit();

    _firstLoad();
  }

  Future<void> _firstLoad() async {
    try {
      final List<GalleryItem> _listItem = await _fetchData();
      change(_listItem, status: RxStatus.success());
    } catch (err) {
      logger.e('$err');
      change(null, status: RxStatus.error(err.toString()));
    }

    try {
      if (_cancelToken.isCancelled) {
        return;
      }
      isBackgroundRefresh = true;
      await reloadData();
    } catch (_) {} finally {
      isBackgroundRefresh = false;
    }
  }

  Future<List<GalleryItem>> _fetchData({bool refresh = false}) async {
    try {
      final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getPopular(
        refresh: refresh,
        cancelToken: _cancelToken,
      );
      final Future<List<GalleryItem>> gallerItemBeans =
          tuple.then((Tuple2<List<GalleryItem>, int> value) => value.item1);
      return gallerItemBeans;
    } catch (e) {
      logger.e('loadData error: $e');
      rethrow;
    }
  }

  Future<void> reloadData() async {
    final List<GalleryItem> gallerItemBeans = await _fetchData(refresh: true);
    change(gallerItemBeans);
  }

  Future<void> onRefresh() async {
    isBackgroundRefresh = false;
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }

    change(state, status: RxStatus.success());
    await reloadData();
  }

  Future<void> reLoadDataFirst() async {
    change(state, status: RxStatus.loading());
    onInit();
  }
}
