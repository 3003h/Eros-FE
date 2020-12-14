import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/base.dart';

import '../index.dart';

class SearchTextModel extends ProfileChangeNotifier {
  Profile get _profile => Global.profile;

  // List<String> _searchTextList = <String>[];

  List<String> get searchTextList => _profile.searchText ?? <String>[];

  set searchTextList(List<String> inSearTextList) =>
      _profile.searchText = inSearTextList;

  bool addText(String text) {
    if (_profile.searchText.contains(text.trim())) {
      return false;
    } else {
      _profile.searchText.add(text);
      notifyListeners();
      return true;
    }
  }

  void removeTextAt(int idx) {
    _profile.searchText.removeAt(idx);
    notifyListeners();
  }

  void removeAll() {
    _profile.searchText.clear();
    notifyListeners();
  }
}
