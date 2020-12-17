import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/network/gallery_request.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class PopularController extends GetxController
    with StateMixin<List<GalleryItem>> {
  @override
  void onInit() {
    super.onInit();

    loadData().then((List<GalleryItem> value) {
      change(value, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    });

    Future<void>.delayed(const Duration(milliseconds: 500)).then((_) {
      reloadData();
    });
  }

  Future<List<GalleryItem>> loadData({bool refresh = false}) async {
    final Future<Tuple2<List<GalleryItem>, int>> tuple =
        Api.getPopular(refresh: refresh);
    final Future<List<GalleryItem>> gallerItemBeans =
        tuple.then((Tuple2<List<GalleryItem>, int> value) => value.item1);
    return gallerItemBeans;
  }

  Future<void> reloadData() async {
    final List<GalleryItem> gallerItemBeans = await loadData(refresh: true);
    change(gallerItemBeans);
  }

  Future<void> reLoadDataFirst() async {
    await loadData();
  }
}
