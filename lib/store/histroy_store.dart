import 'package:get_storage/get_storage.dart';

// ignore: avoid_classes_with_only_static_members
class HistoryStore {
  static final _historyStore = () => GetStorage('History');
}
