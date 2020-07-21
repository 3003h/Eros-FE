import 'base.dart';

class GalleryModel extends ProfileChangeNotifier {
  String _favTitle;

  set setFavTitle(String favTitle) {
    _favTitle = favTitle;
    notifyListeners();
  }

  get favTitle => _favTitle;
}
