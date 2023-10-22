import 'package:get/get.dart';

// String get pageCtrlTag =>
//     Get.find<ControllerTagService>().pageCtrlDepth.toString();

String get searchPageCtrlTag =>
    Get.find<ControllerTagService>().searchPageCtrlDepth.toString();

String get pageCtrlTag => Get.find<ControllerTagService>().currGid;
// String get searchPageCtrlTag => Get.find<ControllerTagService>().currSearchText;

class ControllerTagService extends GetxService {
  final pageGids = <String>[];
  String get currGid => pageGids.isNotEmpty ? pageGids.last : '';

  /// [pageCtrlDepth] 画廊页面的路由深度
  /// 用作控制器的唯一标识
  /// 画廊页会在路由中同时存在多个但是不会平行
  /// 所以使用该变量可获取当前深度的控制器实例
  int pageCtrlDepth = 0;

  // 路由入栈时 深度+1
  void pushPageCtrl({String? gid}) {
    pageCtrlDepth++;
    if (gid != null) {
      pageGids.add(gid);
    }
    // logger.t('pushPageCtrl to $pageCtrlDepth');
  }

  // 出栈 深度-1 放在onClose事件中
  void popPageCtrl() {
    pageCtrlDepth--;
    pageGids.removeLast();
    // logger.t('popPageCtrl to $pageCtrlDepth');
  }

  final searchTextList = <String>[];
  String get currSearchText => searchTextList.last;

  /// [searchPageCtrlDepth] 搜索页深度
  /// 作为控制器唯一标识
  int searchPageCtrlDepth = 0;

  void pushSearchPageCtrl({String? searchText}) {
    searchPageCtrlDepth++;
    if (searchText != null) {
      searchTextList.add(searchText);
    } else {
      searchTextList.add(searchPageCtrlDepth.toString());
    }
    // logger.d('pushSearchPageCtrl to $searchPageCtrlDepth');
  }

  void popSearchPageCtrl() {
    searchPageCtrlDepth--;
    searchTextList.removeLast();
    // logger.d('pushSearchPageCtrl to $searchPageCtrlDepth');
  }
}
