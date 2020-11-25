import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/base.dart';

class AdvanceSearchModel extends ProfileChangeNotifier {
  AdvanceSearch get advanceSearch => Global.profile.advanceSearch;

  bool get enable => Global.profile.enableAdvanceSearch ?? false;
  set enable(bool value) {
    Global.profile.enableAdvanceSearch = value;
    notifyListeners();
  }
}
