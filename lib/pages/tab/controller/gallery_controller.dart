import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class GalleryController extends GetxController {
  GalleryController({@required this.cats, @required this.simpleSearch});
  int cats;
  String simpleSearch;

  final RxList<GalleryItem> _frontGallerItemBeans = <GalleryItem>[].obs;

  RxList<GalleryItem> get frontGallerItemBeans => _frontGallerItemBeans;
  set frontGallerItemBeans(List<GalleryItem> frontGallerItemBeans) {
    _frontGallerItemBeans.clear();
    _frontGallerItemBeans.addAll(frontGallerItemBeans);
  }

  int curPage = 0;
  int maxPage = 0;

  RxBool isLoadMore = false.obs;

  String _search = '';

  Rx<Future<Tuple2<List<GalleryItem>, int>>> futureBuilderFuture =
      Future.value(const Tuple2<List<GalleryItem>, int>(<GalleryItem>[], 0))
          .obs;
  Widget lastListWidget;

  String get title =>
      (_search != null && _search.isNotEmpty) ? _search : 'tab_gallery'.tr;

  //页码跳转的控制器
  final TextEditingController _pageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _search = simpleSearch?.trim() ?? '';
    futureBuilderFuture.value = loadData();
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      reloadData();
    });
  }

  Future<Tuple2<List<GalleryItem>, int>> loadData(
      {bool refresh = false}) async {
    Global.logger.v('_loadDataFirstF  gallery');
    final int _catNum =
        Provider.of<EhConfigModel>(Get.context, listen: false).catFilter;

    final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getGallery(
      cats: cats ?? _catNum,
      serach: _search,
      refresh: refresh,
    );
    return tuple;
  }

  Future<void> reloadData() async {
    curPage = 0;
    final Tuple2<List<GalleryItem>, int> tuple = await loadData(
      refresh: true,
    );
    futureBuilderFuture.value =
        Future<Tuple2<List<GalleryItem>, int>>.value(tuple);
  }

  Future<void> reLoadDataFirst() async {
    futureBuilderFuture.value = loadData(refresh: true);
  }

  Future<void> loadDataMore({bool cleanSearch = false}) async {
    if (isLoadMore.value) {
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum =
        Provider.of<EhConfigModel>(Get.context, listen: false).catFilter;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    isLoadMore.value = true;

    Global.logger.d('${frontGallerItemBeans.length}');

    curPage += 1;
    final String fromGid = frontGallerItemBeans.last.gid;
    final Tuple2<List<GalleryItem>, int> tuple = await Api.getGallery(
      page: curPage,
      fromGid: fromGid,
      cats: cats ?? _catNum,
      serach: _search,
      refresh: true,
    );
    final List<GalleryItem> gallerItemBeans = tuple.item1;

    frontGallerItemBeans.addAll(gallerItemBeans);
    Global.logger.d('${frontGallerItemBeans.length}');
    maxPage = tuple.item2;
    isLoadMore.value = false;
  }

  Future<void> loadFromPage(int page, {bool cleanSearch = false}) async {
    Global.logger.v('jump to page =>  $page');

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum =
        Provider.of<EhConfigModel>(Get.context, listen: false).catFilter;
    curPage = page;
    final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getGallery(
      page: curPage,
      cats: cats ?? _catNum,
      serach: _search,
      refresh: true,
    );

    lastListWidget = null;
    futureBuilderFuture.value = tuple;
  }

  /// 跳转页码
  Future<void> jumpToPage() async {
    void _jump() {
      final String _input = _pageController.text.trim();

      if (_input.isEmpty) {
        showToast('输入为空');
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast('输入格式有误');
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= maxPage) {
        FocusScope.of(Get.context).requestFocus(FocusNode());
        loadFromPage(_toPage);
        Get.back();
      } else {
        showToast('输入范围有误');
      }
    }

    return showCupertinoDialog<void>(
      context: Get.overlayContext,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('页面跳转'),
          content: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('跳转范围 1~$maxPage'),
                ),
                CupertinoTextField(
                  controller: _pageController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    // 点击键盘完成
                    // 画廊跳转
                    _jump();
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                // 画廊跳转
                _jump();
              },
            ),
          ],
        );
      },
    );
  }
}
