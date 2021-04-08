import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/dns_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'base_service.dart';

const String _regExpIP = r'(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}';
const String _regExpHost =
    r'^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$';

class DnsService extends ProfileService {
  RxBool enableCustomHosts = false.obs;
  RxBool enableDoH = false.obs;
  RxBool enableDomainFronting = false.obs;
  final RxList<DnsCache> _hosts = <DnsCache>[].obs;
  final RxList<DnsCache> _dohCache = <DnsCache>[].obs;

  RxList<DnsCache> get hosts => _hosts;

  RxList<DnsCache> get dohCache => _dohCache;

  void removeCustomHostAt(int index) {
    _hosts.removeAt(index);
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
      final int index =
          _hosts.indexWhere((DnsCache element) => element.host == host);
      if (index < 0) {
        _hosts.add(DnsCache(
          host: host,
          addr: addr,
          ttl: 0,
          lastResolve: 0,
          addrs: [],
        ));
      } else {
        // _hosts[index].addr = addr;
        _hosts[index] = _hosts[index].copyWith(addr: addr);
      }

      logger.v('add $host => $addr');
      // notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateDoHCache(String host) async {
    if (host == 'cloudflare-dns.com') {
      return;
    }

    // 24小时
    const int updateInterval = 86400;

    final int index =
        dohCache.indexWhere((DnsCache element) => element.host == host);
    final DnsCache? dnsCache = index >= 0 ? dohCache[index] : null;
    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    if (dnsCache != null) {
      if (dnsCache.lastResolve != null &&
          nowTime - (dnsCache.lastResolve ?? -1) > updateInterval) {
        logger.wtf(' updateDoHCache $host');
        // get new and cache
        final String _addr = await DnsUtil.doh(host);
        // dnsCache
        //   ..lastResolve = nowTime
        //   ..addr = _addr;
        dohCache[index] = dnsCache.copyWith(lastResolve: nowTime, addr: _addr);
      }
    } else {
      // get new
      logger.wtf(' get new doh $host');
      final String _addr = await DnsUtil.doh(host);
      // logger.d(' get new doh $host  addr=$_addr');
      dohCache.add(DnsCache(
        host: host,
        lastResolve: nowTime,
        addr: _addr,
        ttl: -1,
        addrs: [],
      ));
    }
  }

  @override
  void onInit() {
    super.onInit();
    final DnsConfig _dnsConfig = Global.profile.dnsConfig;
    enableCustomHosts.value = _dnsConfig.enableCustomHosts ?? false;
    _hosts(_dnsConfig.hosts);
    _dohCache(_dnsConfig.dohCache);

    ever<bool>(enableCustomHosts as RxInterface<bool>, (bool value) {
      // _dnsConfig.enableCustomHosts = value;
      Global.profile = Global.profile
          .copyWith(dnsConfig: _dnsConfig.copyWith(enableCustomHosts: value));
      Global.saveProfile();
    });
    ever<List<DnsCache>>(_hosts, (List<DnsCache> value) {
      // _dnsConfig.hosts = value;
      Global.profile =
          Global.profile.copyWith(dnsConfig: _dnsConfig.copyWith(hosts: value));
      Global.saveProfile();
    });

    ever<bool>(enableDoH as RxInterface<bool>, (bool value) {
      // _dnsConfig.enableDoH = value;
      Global.profile = Global.profile
          .copyWith(dnsConfig: _dnsConfig.copyWith(enableDoH: value));
      Global.saveProfile();
    });
    enableDoH.value = _dnsConfig.enableDoH ?? false;
    everProfile<List<DnsCache>>(_dohCache, (List<DnsCache> value) {
      // _dnsConfig.dohCache = value;
      Global.profile = Global.profile
          .copyWith(dnsConfig: _dnsConfig.copyWith(dohCache: value));
    });

    enableDomainFronting.value = _dnsConfig.enableDomainFronting ?? false;
    everProfile<bool>(enableDomainFronting as RxInterface<bool>, (bool value) {
      // _dnsConfig.enableDomainFronting = value;
      Global.profile = Global.profile.copyWith(
          dnsConfig: _dnsConfig.copyWith(enableDomainFronting: value));
    });
  }
}
