import 'package:flutter/cupertino.dart';

import '../fehviewer.dart';

class LinkScrollBarController extends ChangeNotifier {
  LinkScrollBarController({this.initIndex = 0});

  final int initIndex;

  bool canScrollToItem = true;
  void disableScrollToItem() {
    canScrollToItem = false;
  }

  void enableScrollToItem() {
    canScrollToItem = true;
  }

  ValueChanged<int>? scrollToItemCall;
  void scrollToItem(int index) {
    if (canScrollToItem) {
      scrollToItemCall?.call(index);
    }
  }
}
