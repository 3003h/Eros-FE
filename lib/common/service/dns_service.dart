import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
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
  // RxBool enableCustomHosts = false.obs;
  final _enableCustomHosts = false.obs;
  bool get enableCustomHosts => _enableCustomHosts.value;
  set enableCustomHosts(val) => _enableCustomHosts.value = val;

  // RxBool enableDoH = false.obs;
  final _enableDoH = false.obs;
  bool get enableDoH => _enableDoH.value;
  set enableDoH(val) => _enableDoH.value = val;

  // RxBool enableDomainFronting = false.obs;
  final _enableDomainFronting = false.obs;
  bool get enableDomainFronting => _enableDomainFronting.value;
  set enableDomainFronting(val) => _enableDomainFronting.value = val;

  final RxList<DnsCache> _hosts = <DnsCache>[].obs;
  final RxList<DnsCache> _dohCache = <DnsCache>[].obs;

  RxList<DnsCache> get hosts => _hosts;

  RxList<DnsCache> get dohCache => _dohCache;

  Map<String, String> get hostMap {
    final _map = <String, String>{};
    for (final dc in hosts) {
      if (dc.host != null && dc.addr != null) {
        _map.putIfAbsent(dc.host!, () => dc.addr!);
      }
    }
    return _map;
  }

  Map<String, String> get hostMapMerge {
    final coutomHosts = hostMap;

    // 预置列表
    if (enableCustomHosts) {
      for (final host in EHConst.internalHosts.entries) {
        coutomHosts.putIfAbsent(host.key, () => host.value);
      }
    } else {
      return EHConst.internalHosts;
    }

    return coutomHosts;
  }

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

  Future<DnsCache?> getDoHCache(String host) async {
    if (host == 'cloudflare-dns.com') {
      return null;
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
        logger.d('updateDoHCache $host');
        // get new and cache
        final String? _addr = await DnsUtil.doh(host);
        final _dc = dnsCache.copyWith(lastResolve: nowTime, addr: _addr);
        dohCache[index] = _dc;
        logger.d('rult ${_dc.toJson()}');
        return _dc;
      }
    } else {
      // get new
      logger.d('get new doh $host');
      final String? _addr = await DnsUtil.doh(host);
      logger.d(' get new doh $host  addr=$_addr');
      final _dc = DnsCache(
        host: host,
        lastResolve: nowTime,
        addr: _addr,
        ttl: -1,
        addrs: [],
      );
      dohCache.add(_dc);
      // logger.d(_dc.toJson());
      return _dc;
    }
  }

  @override
  void onInit() {
    super.onInit();

    enableCustomHosts = dnsConfig.enableCustomHosts ?? false;
    everProfile<bool>(_enableCustomHosts, (bool value) {
      dnsConfig = dnsConfig.copyWith(enableCustomHosts: value);
    });

    _hosts(dnsConfig.hosts);
    everProfile<List<DnsCache>>(_hosts, (List<DnsCache> value) {
      dnsConfig = dnsConfig.copyWith(hosts: value);
    });

    enableDoH = dnsConfig.enableDoH ?? false;
    everProfile<bool>(_enableDoH, (bool value) {
      dnsConfig = dnsConfig.copyWith(enableDoH: value);
    });

    _dohCache(dnsConfig.dohCache);
    everProfile<List<DnsCache>>(_dohCache, (List<DnsCache> value) {
      dnsConfig = dnsConfig.copyWith(dohCache: value);
    });

    enableDomainFronting = dnsConfig.enableDomainFronting ?? false;
    everProfile<bool>(_enableDomainFronting, (bool value) {
      dnsConfig = dnsConfig.copyWith(enableDomainFronting: value);
    });
  }
}
