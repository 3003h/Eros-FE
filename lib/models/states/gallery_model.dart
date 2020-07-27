import 'package:FEhViewer/models/index.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class GalleryModel extends ProfileChangeNotifier {
  GalleryItem _galleryItem;
  var _tabindex;
  var _title;

  initData(GalleryItem galleryItem, {@required tabIndex}) {
    _galleryItem = galleryItem;
    _tabindex = tabIndex;
  }

  GalleryItem get galleryItem => _galleryItem;

  set title(String title) {
    _title = title;
    notifyListeners();
  }

  get title => _title;

  get tabIndex => _tabindex;
}
