import 'package:FEhViewer/models/index.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class GalleryModel extends ProfileChangeNotifier {
  GalleryItem _galleryItem;
  List<GalleryPreview> _oriGalleryPreview;
  dynamic _tabindex;
  String _title;
  int _currentPreviewPage;
  bool _isGetAllImageHref;
  bool _hideNavigationBtn = true;
  bool _detailLoadFinish;

  void initData(GalleryItem galleryItem, {@required tabIndex}) {
    _galleryItem = galleryItem;
    _tabindex = tabIndex;
    _currentPreviewPage = 0;
  }

  // todo 待优化 直接暴露_galleryItem会导致随意写入数据
  GalleryItem get galleryItem => _galleryItem;

  void setGalleryPreview(List<GalleryPreview> galleryPreview) {
    if (galleryPreview.isNotEmpty) {
      _galleryItem.galleryPreview = galleryPreview;
    }

    _oriGalleryPreview =
        _galleryItem.galleryPreview.sublist(0, galleryPreview.length);
//    notifyListeners();
  }

  void setFavTitle(String favTitle, {String favcat}) {
    _galleryItem.favTitle = favTitle;
    if (favcat != null) {
      _galleryItem.favcat = favcat;
    }
    notifyListeners();
  }

  void addAllPreview(List<GalleryPreview> galleryPreview) {
    _galleryItem.galleryPreview.addAll(galleryPreview);
//    Global.logger.v('${_galleryItem.galleryPreview.length}');
    notifyListeners();
  }

  void resetHideNavigationBtn() {
    _hideNavigationBtn = true;
  }

  set hideNavigationBtn(bool value) {
    _hideNavigationBtn = value;
    notifyListeners();
  }

  bool get hideNavigationBtn => _hideNavigationBtn;

  bool get isGetAllImageHref => _isGetAllImageHref ?? false;
  set isGetAllImageHref(bool value) => _isGetAllImageHref = value;

  List<GalleryPreview> get previews => _galleryItem.galleryPreview;

  List<GalleryPreview> get oriGalleryPreview => _oriGalleryPreview ?? [];

  set detailLoadFinish(bool value) => _detailLoadFinish = value;
  bool get detailLoadFinish => _detailLoadFinish ?? false;

  dynamic get title => _title;

  dynamic get tabIndex => _tabindex;

  String get showKey => _galleryItem.showKey;

  int get currentPreviewPage {
    _currentPreviewPage ??= 0;
    return _currentPreviewPage;
  }

  set currentPreviewPage(int page) {
    _currentPreviewPage = page;
  }

  void currentPreviewPageAdd() {
    _currentPreviewPage++;
  }
}
