import 'dart:convert';

import 'package:eros_fe/index.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path/path.dart' if (dart.library.html) 'src/stub/path.dart'
    as path_helper;

const kCacheBox = 'cacheBox';

const kUsersKey = 'users_info';

class HiveCacheHelper {
  HiveCacheHelper();

  static final _cacheBox = Hive.box<String>(kCacheBox);

  Future<void> init() async {
    // WidgetsFlutterBinding.ensureInitialized();

    Hive.init(path_helper.join(Global.tempPath, 'hive'));

    await openBox();
  }

  Future<void> openBox() async {
    await Hive.openBox<String>(
      kCacheBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.t('entries $entries');
        return entries > 10;
      },
    );
  }

  Future<void> setUsersInfo(List<User> users) async {
    await _cacheBox.put(kUsersKey, jsonEncode(users));
  }

  List<User> getUsersInfo() {
    final all = _cacheBox.get(kUsersKey, defaultValue: '[]');

    final _users = <User>[];
    for (final val in jsonDecode(all ?? '[]') as List<dynamic>) {
      _users.add(User.fromJson(val as Map<String, dynamic>));
    }
    return _users;
  }
}
