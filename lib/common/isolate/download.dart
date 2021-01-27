import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_detail_parser.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart' hide CacheConfig;
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/db/dao/image_task_dao.dart';
import 'package:fehviewer/store/db/entity/gallery_image_task.dart';
import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;

final DownloadManager downloadManager = DownloadManager();

enum IsoTaskState {
  INIT,
  APPEND,
  INITDTL,
  PROGRESS,
  ERROR,
  COMPLETE,
}

class IsoContactBean {
  IsoContactBean({
    this.state,
    this.data,
    this.appSupportPath,
    this.appDocPath,
    this.isSiteEx,
    this.previews,
    this.progess,
  });

  final IsoTaskState state;
  final dynamic data;
  final String appSupportPath;
  final String appDocPath;
  final bool isSiteEx;
  final List<GalleryPreview> previews;
  final ProgessBean progess;
}

class ProgessBean {
  ProgessBean({
    this.totCount,
    this.completCount,
    this.updateImages,
  });
  final int totCount;
  final int completCount;
  final List<GalleryImageTask> updateImages;
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

    final ImageTaskDao _imageTaskDao =
        await DownloadController.getImageTaskDao();

    // 监听子 isolate 发过来的消息
    _receivePort.listen((message) async {
      try {
        final IsoContactBean _isoContactBean = message;
        switch (_isoContactBean.state) {
          case IsoTaskState.INIT:
            // 初始化 获取子isolate的 sendPort
            _sendPortToChild = _isoContactBean.data;
            break;
          case IsoTaskState.INITDTL: // 明细更新
            final List<GalleryPreview> _rultPreviews = _isoContactBean.previews;
            final GalleryTask _initGalleryTask = _isoContactBean.data;
            // 更新状态
            final GalleryPageController _pageController =
                Get.find(tag: pageCtrlDepth);
            logger.d(
                '${_pageController.previews.length} ${_rultPreviews.length}');
            if (_pageController.previews.length < _rultPreviews.length) {
              logger.d('set pre');
              _pageController.previews.clear();
              _pageController.previews.addAll(_rultPreviews);
            }

            // 明细入库
            // 插入所有任务明细
            final List<GalleryImageTask> _galleryImageTasks = _rultPreviews
                .map((GalleryPreview e) => GalleryImageTask(
                      gid: _initGalleryTask.gid,
                      token: _initGalleryTask.token,
                      href: e.href,
                      ser: e.ser,
                    ))
                .toList();
            _imageTaskDao.insertImageTasks(_galleryImageTasks);

            logger.v('insert end');

            // 测试插入结果
            final List<GalleryImageTask> _list = await _imageTaskDao
                .findAllGalleryTaskByGid(_initGalleryTask.gid);
            logger.d('${_list.map((e) => e.toString()).join('\n')} ');

            break;
          case IsoTaskState.PROGRESS: // 进度更新
            // 更新明细大图url
            final ProgessBean _progess = _isoContactBean.progess;
            final GalleryTask _initGalleryTask = _isoContactBean.data;
            // logger.v(
            //     'progess  ${_progess.updateImages.map((e) => e.toString()).join('\n')}');
            for (final GalleryImageTask _uptImageTask
                in _progess.updateImages) {
              final GalleryImageTask _oriImageTask = await _imageTaskDao
                  .findGalleryTaskByKey(_uptImageTask.gid, _uptImageTask.ser);

              final GalleryImageTask _uptTask =
                  _oriImageTask.copyWith(imageUrl: _uptImageTask.imageUrl);
              await _imageTaskDao.updateImageTask(_uptTask);
            }

            break;
          case IsoTaskState.COMPLETE: // 下载完成
            logger.i('${_isoContactBean.data}');

            showToast('${_isoContactBean.data}');
            break;
          case IsoTaskState.ERROR:
            break;
          default:
            break;
        }
      } catch (e, stack) {
        logger.e('$e\n$stack');
      }
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
      appDocPath: Global.appDocPath,
      previews: _pageController.firstPagePreview,
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

  final bool _inDebugMode = EHUtils().isInDebugMode;

  // 监听父isolate消息
  _receivePort.listen((message) async {
    try {
      final IsoContactBean _isoContactBean = message;
      switch (_isoContactBean.state) {
        case IsoTaskState.ERROR:
          break;
        case IsoTaskState.APPEND: // 添加下载任务
          final GalleryTask _initGalleryTask = _isoContactBean.data;
          logger.d(
              'isolate add task ${_initGalleryTask.gid} ${_initGalleryTask.title}');

          // 获取所有图片页的href
          final List<GalleryPreview> _previews = await _getAllPreviews(
            url: _initGalleryTask.url,
            fileCount: _initGalleryTask.fileCount,
            appSupportPath: _isoContactBean.appSupportPath,
            isSiteEx: _isoContactBean.isSiteEx,
            initPreviews: _isoContactBean.previews,
          );

          logger.d('${_previews.length}');

          // 发送获取结果到父iso 更新明细库
          sendPort.send(
            IsoContactBean(
              state: IsoTaskState.INITDTL,
              data: _initGalleryTask,
              previews: _previews,
            ),
          );

          // 依次获取大图url 更新明细
          for (final GalleryPreview preview in _previews) {
            // logger.d('get imageUrl ${preview.ser}');

            try {
              final GalleryPreview _info = await _isoParaImageLageInfoFromHtml(
                preview.href,
                isSiteEx: _isoContactBean.isSiteEx,
                appSupportPath: _isoContactBean.appSupportPath,
              );
              // logger.d('iso ${preview.ser} => ${_info.largeImageUrl}');
              final ProgessBean _progessBean = ProgessBean(updateImages: [
                GalleryImageTask(
                  gid: _initGalleryTask.gid,
                  ser: preview.ser,
                  imageUrl: _info.largeImageUrl,
                ),
              ]);
              // 发送消息回父isolate 更新数据库记录
              sendPort.send(
                IsoContactBean(
                  state: IsoTaskState.PROGRESS,
                  data: _initGalleryTask,
                  progess: _progessBean,
                ),
              );
            } catch (e) {
              logger.d('$e');
            }
          }

          // 发送消息回父isolate
          sendPort.send(
            IsoContactBean(
              state: IsoTaskState.COMPLETE,
              data:
                  'gid:${_initGalleryTask.gid} => previews[${_previews.length}]',
              previews: _previews,
            ),
          );
          break;
        default:
          break;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      // rethrow;
    }
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
          await _isoFetchGalleryPreview(
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
Future<Dio> _getIsolateDio({bool isSiteEx, String appSupportPath}) async {
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

  // Cookie管理
  final PersistCookieJar cookieJar = PersistCookieJar(dir: appSupportPath);
  final CookieManager _cookieManager = CookieManager(cookieJar);
  _dio.interceptors.add(_cookieManager);

  // // 缓存
  _dio.interceptors.add(DioCacheManager(
    CacheConfig(
      databasePath: appSupportPath,
      baseUrl: Api.getBaseUrl(isSiteEx: isSiteEx),
    ),
  ).interceptor);

  return _dio;
}

/// 获取画廊缩略图
/// [inUrl] 画廊的地址
/// [page] 缩略图页码
Future<List<GalleryPreview>> _isoFetchGalleryPreview(
  String inUrl, {
  @required String appSupportPath,
  bool isSiteEx,
  int page,
  bool refresh = true,
  CancelToken cancelToken,
}) async {
  final PersistCookieJar cookieJar = PersistCookieJar(dir: appSupportPath);
  final String _baseUrl = EHConst.getBaseSite(isSiteEx ?? false);
  final String url = inUrl + '?p=$page';

  final List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(_baseUrl));
  cookies.add(Cookie('nw', '1'));
  cookieJar.saveFromResponse(Uri.parse(_baseUrl), cookies);

  final Dio _isolateDio = await _getIsolateDio(
    isSiteEx: isSiteEx,
    appSupportPath: appSupportPath,
  );

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

/// 由api获取画廊图片的信息
/// [href] 爬取的页面地址 用来解析gid 和 imgkey
/// [page] 索引 从 1 开始
Future<GalleryPreview> _isoParaImageLageInfoFromHtml(
  String href, {
  bool refresh = true,
  bool isSiteEx,
  @required String appSupportPath,
}) async {
  final String url = href;

  final Dio _isolateDio = await _getIsolateDio(
    isSiteEx: isSiteEx,
    appSupportPath: appSupportPath,
  );

  Response<String> response;
  try {
    response = await _isolateDio.get<String>(url,
        options: Api.getCacheOptions(forceRefresh: refresh));
  } on DioError catch (e, stack) {
    logger.e('getHttp exception: $e\n$stack');
    rethrow;
  }

  // logger.d('res $response');

  final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
  final String imageUrl = regImageUrl.firstMatch(response.data).group(1);

  // logger.d('imageUrl $imageUrl');

  final RegExpMatch _xy =
      RegExp(r'::\s+(\d+)\s+x\s+(\d+)\s+::').firstMatch(response.data);
  final double width = double.parse(_xy.group(1));
  final double height = double.parse(_xy.group(2));

  final GalleryPreview _rePreview = GalleryPreview()
    ..largeImageUrl = imageUrl
    ..largeImageWidth = width
    ..largeImageHeight = height;

  return _rePreview;
}
