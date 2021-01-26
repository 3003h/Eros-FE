import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_detail_parser.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart' hide CacheConfig;
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;

final DownloadManager downloadManager = DownloadManager();

enum IsoTaskState {
  INIT,
  APPEND,
  PROGRESS,
  ERROR,
  COMPLETE,
}

class IsoContactBean {
  IsoContactBean({
    this.state,
    this.data,
    this.appSupportPath,
    this.isSiteEx,
    this.initPreviews,
  });

  final IsoTaskState state;
  final dynamic data;
  final String appSupportPath;
  final bool isSiteEx;
  final List<GalleryPreview> initPreviews;
}

class DownloadManager {
  final ReceivePort _receivePort = ReceivePort();
  SendPort _sendPortToChild;
  Isolate _isolate;

  /// 初始化
  Future<void> init() async {
    if (_receivePort.isBroadcast) {
      return;
    }
    logger.i('isolate DownloadManager init');

    // isolate spawn
    _isolate = await Isolate.spawn(_isolateDownload, _receivePort.sendPort,
        debugName: 'downloadChildIsolate');

    // 监听子 isolate 发过来的消息
    _receivePort.listen((message) {
      try {
        final IsoContactBean isoContactBean = message;
        switch (isoContactBean.state) {
          case IsoTaskState.INIT:
            _sendPortToChild = isoContactBean.data;
            break;
          case IsoTaskState.PROGRESS:
            break;
          case IsoTaskState.COMPLETE:
            logger.i('${isoContactBean.data}');
            break;
          case IsoTaskState.ERROR:
            break;
          default:
            break;
        }
      } catch (_) {}
    });
  }

  /// 关闭
  void close() {
    _isolate?.kill(priority: Isolate.immediate);
  }

  void addTask({GalleryTask galleryTask}) {
    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final IsoContactBean _isoContactBean = IsoContactBean(
      state: IsoTaskState.APPEND,
      data: galleryTask,
      isSiteEx: Get.find<EhConfigService>().isSiteEx.value ?? false,
      appSupportPath: Global.appSupportPath,
      initPreviews: _pageController.firstPagePreview,
    );
    _sendPortToChild?.send(_isoContactBean);
  }
}

/// isoload下载入口函数
void _isolateDownload(SendPort sendPort) {
  logger.d('init _isolateDownload');
  // 创建一个消息接收器
  final ReceivePort _receivePort = ReceivePort();
  sendPort.send(
      IsoContactBean(state: IsoTaskState.INIT, data: _receivePort.sendPort));

  // 监听父isolate消息
  _receivePort.listen((message) async {
    final IsoContactBean isoContactBean = message;
    switch (isoContactBean.state) {
      case IsoTaskState.ERROR:
        break;
      case IsoTaskState.APPEND: // 添加下载任务
        final GalleryTask _initGalleryTask = isoContactBean.data;
        logger.d(
            'isolate add task ${_initGalleryTask.gid} ${_initGalleryTask.title}');

        final List<GalleryPreview> _previews = await _getAllPreviews(
          url: _initGalleryTask.url,
          fileCount: _initGalleryTask.fileCount,
          appSupportPath: isoContactBean.appSupportPath,
          isSiteEx: isoContactBean.isSiteEx,
          initPreviews: isoContactBean.initPreviews,
        );

        logger.d('${_previews.length}');

        // 发送消息回父isolate
        sendPort.send(
          IsoContactBean(
            state: IsoTaskState.COMPLETE,
            data: 'title => ${_initGalleryTask.title}',
          ),
        );
        break;
      default:
        break;
    }
  }, onError: (e, stack) {
    logger.e(e.toString());
  });
}

/// 获取所有href
Future<List<GalleryPreview>> _getAllPreviews({
  String url,
  List<GalleryPreview> initPreviews,
  int fileCount,
  @required String appSupportPath,
  @required bool isSiteEx,
}) async {
  if (initPreviews != null &&
      initPreviews.isNotEmpty &&
      initPreviews.length == fileCount) {
    return initPreviews;
  }

  final List<GalleryPreview> _rultList = [];
  _rultList.addAll(initPreviews ?? []);
  int _curPage = 0;
  while (_rultList.length < fileCount) {
    try {
      final List<GalleryPreview> _moreGalleryPreviewList =
          await _getGalleryPreview(
        url,
        page: _curPage + 1,
        refresh: true,
        appSupportPath: appSupportPath,
        isSiteEx: isSiteEx,
      );

      logger
          .d(' _moreGalleryPreviewList len ${_moreGalleryPreviewList.length}');

      // 避免重复添加
      if (_rultList.isEmpty ||
          (_rultList.isNotEmpty &&
              _moreGalleryPreviewList.first.ser > _rultList.last.ser)) {
        logger.d('下载任务 添加图片对象 起始序号${_moreGalleryPreviewList.first.ser}  '
            '数量${_moreGalleryPreviewList.length}');
        _rultList.addAll(_moreGalleryPreviewList);
      }
      // 成功后才+1
      _curPage++;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }

  return _rultList;
}

const int _connectTimeout = 20000;
const int _receiveTimeout = 10000;
Dio _getIsolateDio({bool isSiteEx}) {
  Dio _dio;
  BaseOptions _options;

  final String _baseUrl = EHConst.getBaseSite(isSiteEx ?? false);
  _options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      //设置请求头
      headers: <String, String>{
        'User-Agent': EHConst.CHROME_USER_AGENT,
        'Accept': EHConst.CHROME_ACCEPT,
        'Accept-Language': EHConst.CHROME_ACCEPT_LANGUAGE,
      },
      //默认值是"application/json; charset=utf-8",Headers.formUrlEncodedContentType会自动编码请求体.
      contentType: Headers.formUrlEncodedContentType,
      //共有三种方式json,bytes(响应字节),stream（响应流）,plain
      responseType: ResponseType.json);
  _dio = Dio(_options);

  return _dio;
}

/// 获取画廊缩略图
/// [inUrl] 画廊的地址
/// [page] 缩略图页码
Future<List<GalleryPreview>> _getGalleryPreview(
  String inUrl, {
  @required String appSupportPath,
  bool isSiteEx,
  int page,
  bool refresh = false,
  CancelToken cancelToken,
}) async {
  final PersistCookieJar cookieJar = PersistCookieJar(dir: appSupportPath);
  final String _baseUrl = EHConst.getBaseSite(isSiteEx ?? false);
  final String url = inUrl + '?p=$page';

  final List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(_baseUrl));
  cookies.add(Cookie('nw', '1'));
  cookieJar.saveFromResponse(Uri.parse(_baseUrl), cookies);

  final Dio _isolateDio = _getIsolateDio(isSiteEx: isSiteEx);

  // Cookie管理
  final CookieManager _cookieManager = CookieManager(cookieJar);
  _isolateDio.interceptors.add(_cookieManager);

  // 缓存
  _isolateDio.interceptors.add(DioCacheManager(
    CacheConfig(
      databasePath: Global.appSupportPath,
      baseUrl: Api.getBaseUrl(isSiteEx: isSiteEx),
    ),
  ).interceptor);

  logger.v('$url');

  Response<String> response;
  try {
    response = await _isolateDio.get<String>(url,
        options: Api.getCacheOptions(forceRefresh: refresh),
        cancelToken: cancelToken);
  } on DioError catch (e, stack) {
    logger.e('getHttp exception: $e\n$stack');
    rethrow;
  }

  // logger.d('${response.data}');

  return GalleryDetailParser.parseGalleryPreviewFromHtml(response.data);
}
