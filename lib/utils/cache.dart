import 'dart:collection';

import 'package:fehviewer/common/global.dart';
import 'package:dio/dio.dart';

import 'logger.dart';

class CacheObject {
  CacheObject(this.response)
      : timeStamp = DateTime.now().millisecondsSinceEpoch;
  Response response;
  int timeStamp; // 缓存创建时间

  @override
  bool operator ==(other) {
    return response.hashCode == other.hashCode;
  }

  //将请求uri作为缓存的key
  @override
  int get hashCode => response.realUri.hashCode;
}

class NetCache extends Interceptor {
  // 为确保迭代器顺序和对象插入时间一致顺序一致，我们使用LinkedHashMap
  LinkedHashMap<String, CacheObject> cache =
      LinkedHashMap<String, CacheObject>();

  @override
  Future<Object> onRequest(RequestOptions options) async {
    if (!Global.profile.cache.enable) {
      return options;
    }
    // refresh标记是否是"下拉刷新"
    final bool refresh = options.extra['refresh'] == true;

    String _key;
    if (options.method.toLowerCase() == 'get') {
      _key = options.extra['cacheKey'] ?? options.uri.toString();
    } else if (options.method.toLowerCase() == 'post') {
      _key = options.extra['cacheKey'] ?? 'post_${options.uri}_${options.data}';
    }

    //如果是下拉刷新，先删除相关缓存
    if (refresh) {
      if (options.extra['list'] == true) {
        //若是列表，则只要url中包含当前path的缓存全部删除（简单实现，并不精准）
        cache.removeWhere((key, v) => key.contains(options.path));
      } else {
        // 如果不是列表，则只删除uri相同的缓存
        delete(_key);
      }
      return options;
    }
    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      final CacheObject ob = cache[_key];
      if (ob != null) {
        //若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 <
            Global.profile.cache.maxAge) {
          loggerNoStack.d('dio 返回缓存$_key');
          return cache[_key].response;
        } else {
          //若已过期则删除缓存，继续向服务器请求
          cache.remove(_key);
        }
      }
    } else if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'post') {
      final CacheObject ob = cache[_key];
      if (ob != null) {
        //若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 <
            Global.profile.cache.maxAge) {
          loggerNoStack.d('dio 返回缓存$_key');
          return cache[_key].response;
        } else {
          //若已过期则删除缓存，继续向服务器请求
          cache.remove(_key);
        }
      }
    }
    return options;
  }

  @override
  Future<dynamic> onError(DioError err) async {
    // 错误状态不缓存
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response) async {
    // 如果启用缓存，将返回结果保存到缓存
    if (Global.profile.cache.enable) {
      _saveCache(response);
    }
  }

  void _saveCache(Response<dynamic> object) {
    final RequestOptions options = object.request;
    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      // 如果缓存数量超过最大数量限制，则先移除最早的一条记录
      if (cache.length == Global.profile.cache.maxCount) {
        cache.remove(cache[cache.keys.first]);
      }
      final String key = options.extra['cacheKey'] ?? options.uri.toString();
      cache[key] = CacheObject(object);
    } else if (options.method.toLowerCase() == 'post') {
      final String key =
          options.extra['cacheKey'] ?? 'post_${options.uri}_${options.data}';
      cache[key] = CacheObject(object);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }
}
