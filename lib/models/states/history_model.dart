import 'package:FEhViewer/common/global.dart';
import 'package:flutter/foundation.dart';

import '../index.dart';

class HistoryModel with ChangeNotifier {
  History get _history => Global.history;

  int get _max => Global.profile.ehConfig.maxHistory ?? 100;

  List<GalleryItem> get history => _history.history ?? <GalleryItem>[];

  void _saveAndNotifyListeners() {
    Global.saveHistory();
    super.notifyListeners();
  }

  void addHistory(GalleryItem galleryItem) {
    // Global.logger.v('${galleryItem.toJson()}');
    final int _index = history.indexWhere((GalleryItem element) {
      return element.url == galleryItem.url;
    });
    if (_index >= 0) {
      _history.history.removeAt(_index);
      _history.history.insert(0, galleryItem);
    } else {
      // 检查数量限制 超限则删除最后一条
      if (_max > 0 && _history.history.length == _max) {
        _history.history.removeLast();
      }

      _history.history.insert(0, galleryItem);
    }
    _saveAndNotifyListeners();
  }

  void removeHistory(int index) {
    _history.history.removeAt(index);
    _saveAndNotifyListeners();
  }

  void cleanHistory() {
    _history.history.clear();
    _saveAndNotifyListeners();
  }
}
