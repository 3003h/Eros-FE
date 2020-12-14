import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class PopularController extends GetxController {
  Widget lastListWidget;

  Rx<Future<List<GalleryItem>>> futureBuilderFuture =
      Future.value(<GalleryItem>[]).obs;
  RxList<GalleryItem> gallerItemBeans = <GalleryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    futureBuilderFuture.value = loadData();
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
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

    futureBuilderFuture.value =
        Future<List<GalleryItem>>.value(gallerItemBeans);
  }

  Future<void> reLoadDataFirst() async {
    futureBuilderFuture.value = loadData();
  }
}
