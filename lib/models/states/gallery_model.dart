import 'package:FEhViewer/models/index.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class GalleryModel extends ProfileChangeNotifier {
  GalleryItem _galleryItem;
  List<GalleryPreview> _oriGalleryPreview;
  var _tabindex;
  var _title;
  int _currentPreviewPage;
  bool _isGetAllImageHref;
  bool _hideNavigationBtn = true;
  bool _detailLoadFinish;

  initData(GalleryItem galleryItem, {@required tabIndex}) {
    _galleryItem = galleryItem;
    _tabindex = tabIndex;
    _currentPreviewPage = 0;
  }

  // todo 待优化 直接暴露_galleryItem会导致随意写入数据
  GalleryItem get galleryItem => _galleryItem;

  setGalleryPreview(List<GalleryPreview> galleryPreview) {
    if (galleryPreview.isNotEmpty) {
      _galleryItem.galleryPreview = galleryPreview;
    }

    _oriGalleryPreview =
        _galleryItem.galleryPreview.sublist(0, galleryPreview.length);
//    notifyListeners();
  }

  setFavTitle(String favTitle, {String favcat}) {
    _galleryItem.favTitle = favTitle;
    if (favcat != null) {
      _galleryItem.favcat = favcat;
    }
    notifyListeners();
  }

  addAllPreview(List<GalleryPreview> galleryPreview) {
    _galleryItem.galleryPreview.addAll(galleryPreview);
//    Global.logger.v('${_galleryItem.galleryPreview.length}');
    notifyListeners();
  }

  resetHideNavigationBtn() {
    _hideNavigationBtn = true;
  }

  set hideNavigationBtn(bool value) {
    _hideNavigationBtn = value;
    notifyListeners();
  }

  get hideNavigationBtn => _hideNavigationBtn;

  bool get isGetAllImageHref => _isGetAllImageHref ?? false;
  set isGetAllImageHref(bool value) => _isGetAllImageHref = value;

  List<GalleryPreview> get previews => _galleryItem.galleryPreview;

  List<GalleryPreview> get oriGalleryPreview => _oriGalleryPreview ?? [];

  set detailLoadFinish(bool value) => _detailLoadFinish = value;
  get detailLoadFinish => _detailLoadFinish ?? false;

  get title => _title;

  get tabIndex => _tabindex;

  get showKey => _galleryItem.showKey;

  get currentPreviewPage {
    if (_currentPreviewPage == null) {
      _currentPreviewPage = 0;
    }
    return _currentPreviewPage;
  }

  set currentPreviewPage(int page) {
    _currentPreviewPage = page;
  }

  currentPreviewPageAdd() {
    _currentPreviewPage++;
  }
}
