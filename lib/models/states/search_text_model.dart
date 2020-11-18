import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/base.dart';

import '../index.dart';

class SearchTextModel extends ProfileChangeNotifier {
  Profile get _profile => Global.profile;

  // List<String> _searchTextList = <String>[];

  List<String> get searchTextList => _profile.searchText ?? <String>[];

  set searchTextList(List<String> inSearTextList) =>
      _profile.searchText = inSearTextList;

  void addText(String text) {
    _profile.searchText.add(text);
    notifyListeners();
  }

  void removeTextAt(int idx) {
    _profile.searchText.removeAt(idx);
    notifyListeners();
  }
}
