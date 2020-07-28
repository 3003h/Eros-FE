import 'package:FEhViewer/models/index.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class GalleryModel extends ProfileChangeNotifier {
  GalleryItem _galleryItem;
  List<GalleryPreview> _oriGalleryPreview;
  var _tabindex;
  var _title;

  initData(GalleryItem galleryItem, {@required tabIndex}) {
    _galleryItem = galleryItem;
    _tabindex = tabIndex;
  }

  GalleryItem get galleryItem => _galleryItem;

  setGalleryPreview(List<GalleryPreview> galleryPreview) {
    _galleryItem.galleryPreview = galleryPreview;
    _oriGalleryPreview =
        _galleryItem.galleryPreview.sublist(0, galleryPreview.length);
  }

  get oriGalleryPreview => _oriGalleryPreview;

  get title => _title;

  get tabIndex => _tabindex;

  get showKey => _galleryItem.showKey;
}
