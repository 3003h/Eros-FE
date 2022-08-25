import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/dns_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import '../global.dart';
import 'base_service.dart';

const String _regExpIP = r'(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}';
const String _regExpHost =
    r'^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$';

class DnsService extends ProfileService {
  final _enableCustomHosts = false.obs;
  bool get enableCustomHosts => _enableCustomHosts.value;
  set enableCustomHosts(bool val) => _enableCustomHosts.value = val;

  final _enableDoH = false.obs;
  bool get enableDoH => _enableDoH.value;
  set enableDoH(bool val) => _enableDoH.value = val;

  final _enableDomainFronting = false.obs;
  bool get enableDomainFronting => _enableDomainFronting.value;
  set enableDomainFronting(bool val) => _enableDomainFronting.value = val;

  final RxList<DnsCache> _hosts = <DnsCache>[].obs;
  RxList<DnsCache> get hosts => _hosts;

  final RxList<DnsCache> _dohCache = <DnsCache>[].obs;
  RxList<DnsCache> get dohCache => _dohCache;

  Map<String, List<String>> get hostMap {
    final _map = <String, List<String>>{};
    for (final dc in hosts) {
      if (dc.host != null && dc.addr != null) {
        _map.putIfAbsent(dc.host!, () => [dc.addr!]);
      }
    }
    return _map;
  }

  /// 合并 内置host以及自定义host列表
  Map<String, List<String>> get hostMapMerge {
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

  String getHost(String oriHost) {
    if (hostMapMerge[oriHost] == null) {
      return oriHost;
    }
    final tempList = List<String>.from(hostMapMerge[oriHost] ?? [oriHost]);
    // tempList.shuffle();
    // logger.d('host $oriHost: ${tempList.first}');
    return tempList.first;
  }

  void removeCustomHostAt(int index) {
    _hosts.removeAt(index);
  }

  bool addCustomHost(String host, String addr) {
    /// 检查
    if (host.isEmpty) {
      showToast('host invalid');
      return false;
    }
    if (!RegExp(_regExpIP).hasMatch(addr)) {
      showToast('ip invalid');
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
    return null;
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
    globalDioConfig =
        globalDioConfig.copyWith(domainFronting: enableDomainFronting);
    everProfile<bool>(_enableDomainFronting, (bool value) {
      logger.d('everProfile _enableDomainFronting:$value');
      dnsConfig = dnsConfig.copyWith(enableDomainFronting: value);
      globalDioConfig = globalDioConfig.copyWith(domainFronting: value);
    });
  }
}
