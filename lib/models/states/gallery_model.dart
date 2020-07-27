import 'package:FEhViewer/models/index.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class GalleryModel extends ProfileChangeNotifier {
  GalleryItem _galleryItem;
  var _tabindex;

  initData(GalleryItem galleryItem, {@required tabIndex}) {
    _galleryItem = galleryItem;
    _tabindex = tabIndex;
  }

//  set galleryItem(GalleryItem galleryItem) => _galleryItem = galleryItem;

  GalleryItem get galleryItem => _galleryItem;
  setTitle(String title) {
    _galleryItem.englishTitle = title;
    notifyListeners();
  }

  get tabIndex => _tabindex;
}
