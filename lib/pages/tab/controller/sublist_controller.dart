import 'package:english_words/english_words.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'enum.dart';
import 'default_tabview_controller.dart';

/// 控制单个自定义列表
class SubListController extends DefaultTabViewController {
  SubListController();

  @override
  void onInit() {
    wordList = generateWordPairs().take(100).toList();
    super.onInit();
  }

  List<WordPair> wordList = <WordPair>[].obs;
  Future<void> wordListRefresh() async {
    wordList = generateWordPairs().take(100).toList();
    await 1.seconds.delay();
  }

  @override
  Future<void> lastComplete() async {
    super.lastComplete();
    if (curPage < maxPage - 1 &&
        lastItemBuildComplete &&
        pageState != PageState.Loading) {
      // 加载更多
      loadDataMore();
    }
  }
}
