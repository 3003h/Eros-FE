import 'package:flutter/cupertino.dart';

class EhTabController extends ChangeNotifier {
  EhTabController();

  void scrollToTop() {
    scrollToTopCall?.call();
  }

  void scrollToTopRefresh() {
    scrollToTopRefreshCall?.call();
  }

  // 目标state注册这个方法
  Function? scrollToTopCall;

  Function? scrollToTopRefreshCall;
}
