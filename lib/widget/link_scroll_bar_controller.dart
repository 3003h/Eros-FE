import 'package:flutter/cupertino.dart';

import '../fehviewer.dart';

class LinkScrollBarController extends ChangeNotifier {
  LinkScrollBarController({this.initIndex = 0});

  final int initIndex;

  ValueChanged<int>? scrollToItemCall;
  void scrollToItem(int index) {
    scrollToItemCall?.call(index);
  }
}
