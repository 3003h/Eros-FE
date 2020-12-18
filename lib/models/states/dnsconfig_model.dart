import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/dnsCache.dart';
import 'package:fehviewer/models/dnsConfig.dart';
import 'package:fehviewer/models/states/base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';

const String _regExpIP = r'(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}';
const String _regExpHost =
    r'^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$';

class DnsConfigModel extends ProfileChangeNotifier {
  DnsConfig get _dnsConfig => Global.profile.dnsConfig;

  set enableCustomHosts(bool value) {
    _dnsConfig.enableCustomHosts = value;
    notifyListeners();
  }

  bool get enableCustomHosts => _dnsConfig.enableCustomHosts ?? false;

  List<DnsCache> get hosts => _dnsConfig.hosts ?? <DnsCache>[];

  void removeCustomHostAt(int index) {
    _dnsConfig.hosts.removeAt(index);
    notifyListeners();
  }

  bool addCustomHost(String host, String addr) {
    /// 检查
    if (host.isEmpty) {
      showToast('host无效');
      return false;
    }
    if (!RegExp(_regExpIP).hasMatch(addr)) {
      showToast('地址无效');
      return false;
    }
    if (host.isNotEmpty && addr.isNotEmpty) {
      final int index = _dnsConfig.hosts
          .indexWhere((DnsCache element) => element.host == host);
      if (index < 0) {
        _dnsConfig.hosts.add(DnsCache()
          ..host = host
          ..addr = addr);
      } else {
        _dnsConfig.hosts[index].addr = addr;
      }

      logger.v('add $host => $addr');
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
