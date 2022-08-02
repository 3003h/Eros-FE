import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/request.dart';
import 'package:get/get.dart';

const Duration kMaxStale = Duration(days: 1);

class AvatarController extends GetxController {
  final List<User> _cacheUsers = <User>[];

  @override
  void onInit() {
    super.onInit();
    final _c = hiveHelper.getUsersInfo();
    // logger.d('onInit\n${_c.map((e) => e.toJson()).join('\n')} ');
    _cacheUsers.clear();
    _cacheUsers.addAll(_c);
  }

  void clear() {
    _cacheUsers.clear();
  }

  Future<User?> getUser(String userId) async {
    // logger.d('userId $userId');
    final userFromCache =
        _cacheUsers.firstWhereOrNull((e) => e.memberId == userId);

    final nowTime = DateTime.now().millisecondsSinceEpoch;
    if (userFromCache != null &&
        nowTime - (userFromCache.lastUptTime ?? 0) < kMaxStale.inMilliseconds) {
      return userFromCache;
    }

    logger.v('fetch new UserInfo $userId');
    final user = await getUserInfo(userId, forceRefresh: true);
    if (user != null) {
      _addUser(user.copyWith(
        memberId: userId,
        lastUptTime: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    // logger.d('${_cacheUsers.map((e) => e.toJson()).join('\n')} ');

    return user;
  }

  void _addUser(User user) {
    final _index = _cacheUsers.indexWhere((e) => e.memberId == user.memberId);
    if (_index > -1) {
      _cacheUsers[_index] = user;
    } else {
      _cacheUsers.add(user);
    }
    hiveHelper.setUsersInfo(_cacheUsers);
  }

  bool isCached(String userId) {
    return _cacheUsers.any((e) => e.memberId == userId);
  }

  String? getAvatarUrl(String userId) {
    return _cacheUsers.firstWhereOrNull((e) => e.memberId == userId)?.avatarUrl;
  }
}
