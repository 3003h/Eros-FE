import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/image_view/controller/view_controller.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/web/mime_converter.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_storage/shared_storage.dart' as ss;

import '../../network/app_dio/dio_http_cli.dart';
import '../../network/app_dio/http_response.dart';
import '../../network/app_dio/http_transformer.dart';

class DioFileService extends FileService {
  DioFileService({this.ser});
  final int? ser;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    logger.t('DioFileService url $url');
    if (ser == null) {
      return await loadDio(url, headers: headers);
    } else {
      return await loadAsync(ser!);
    }
  }

  Future<FileServiceResponse> loadDio(
    String url, {
    Map<String, String>? headers,
  }) async {
    DioHttpClient dioHttpClient = DioHttpClient(dioConfig: globalDioConfig);
    final options = CacheOptions(
      policy: CachePolicy.request,
      store: MemCacheStore(),
    ).toOptions()
      ..headers = headers
      ..responseType = ResponseType.stream;

    final res = await dioHttpClient.get(
      url,
      // options: Options(
      //   headers: headers,
      //   responseType: ResponseType.stream,
      // ),
      options: options,
      httpTransformer: HttpTransformerBuilder(
        (response) {
          return DioHttpResponse.success(response);
        },
      ),
    );

    if (res.data == null) {
      throw Exception('Response is null');
    }

    return DioGetResponse(res.data as Response);
  }

  Future<FileServiceResponse> loadAsync(int ser) async {
    final downloadOrigImage = Get.find<EhSettingService>().downloadOrigImage;
    final ViewExtController viewExtController = Get.find();
    final galleryImage = await viewExtController.fetchImage(ser);
    if (galleryImage == null) {
      throw Exception('fetchImage error');
    }

    String? filePath;

    if (galleryImage.filePath?.isNotEmpty ?? false) {
      logger.d('图片文件已下载 file... ${galleryImage.filePath}');
      filePath = galleryImage.filePath!;
    }

    if (galleryImage.tempPath?.isNotEmpty ?? false) {
      logger.d('tempPath file... ${galleryImage.tempPath}');
      filePath = galleryImage.tempPath!;
    }

    if (filePath == null) {
      final imageUrl = downloadOrigImage
          ? galleryImage.originImageUrl
          : galleryImage.imageUrl;
      if (imageUrl == null) {
        throw Exception('imageUrl is null');
      }
      return await loadDio(imageUrl);
    } else {
      late Uint8List bytes;
      late String extension;
      if (filePath.isContentUri) {
        final data = await ss.getDocumentContent(Uri.parse(filePath));
        if (data == null) {
          throw Exception('image data is null');
        }
        bytes = data;
      } else {
        final file = File(filePath);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        } else {
          throw Exception('file not exists');
        }
      }
      extension = filePath.split('.').last;

      return MemoryGetResponse(bytes, extension);
    }
  }
}

class MemoryGetResponse implements FileServiceResponse {
  MemoryGetResponse(this.bytes, this.extension);
  final Uint8List bytes;
  final String extension;

  @override
  Stream<List<int>> get content {
    return Stream.value(bytes);
  }

  @override
  int? get contentLength {
    return bytes.length;
  }

  @override
  String? get eTag {
    return null;
  }

  @override
  String get fileExtension {
    return extension;
  }

  @override
  int get statusCode {
    return 200;
  }

  @override
  DateTime get validTill {
    return clock.now().add(const Duration(days: 1));
  }
}

class FileGetResponse implements FileServiceResponse {
  FileGetResponse(this.filePath);
  final String filePath;

  @override
  Stream<List<int>> get content {
    return File(filePath).openRead();
  }

  @override
  int? get contentLength {
    return File(filePath).lengthSync();
  }

  @override
  String? get eTag {
    return null;
  }

  @override
  String get fileExtension {
    return filePath.split('.').last;
  }

  @override
  int get statusCode {
    return 200;
  }

  @override
  DateTime get validTill {
    return clock.now().add(const Duration(days: 1));
  }
}

class DioGetResponse implements FileServiceResponse {
  DioGetResponse(this._response);

  final DateTime _receivedTime = clock.now();

  final Response _response;

  @override
  int get statusCode => _response.statusCode!;

  String? _header(String name) {
    return _response.headers.map[name]?.first;
  }

  @override
  Stream<List<int>> get content {
    return (_response.data as ResponseBody).stream.cast<List<int>>();
  }

  @override
  int? get contentLength {
    final contentLength = _response.headers[Headers.contentLengthHeader]?.first;
    return contentLength != null ? int.tryParse(contentLength) : null;
  }

  @override
  DateTime get validTill {
    // Without a cache-control header we keep the file for a week
    var ageDuration = const Duration(days: 7);
    final controlHeader = _header(HttpHeaders.cacheControlHeader);
    if (controlHeader != null) {
      final controlSettings = controlHeader.split(',');
      for (final setting in controlSettings) {
        final sanitizedSetting = setting.trim().toLowerCase();
        if (sanitizedSetting == 'no-cache') {
          ageDuration = const Duration();
        }
        if (sanitizedSetting.startsWith('max-age=')) {
          var validSeconds = int.tryParse(sanitizedSetting.split('=')[1]) ?? 0;
          if (validSeconds > 0) {
            ageDuration = Duration(seconds: validSeconds);
          }
        }
      }
    }

    return _receivedTime.add(ageDuration);
  }

  @override
  String? get eTag => _header(HttpHeaders.etagHeader);

  @override
  String get fileExtension {
    var fileExtension = '';
    final contentTypeHeader = _header(HttpHeaders.contentTypeHeader);
    if (contentTypeHeader != null) {
      final contentType = ContentType.parse(contentTypeHeader);
      fileExtension = contentType.fileExtension;
    }
    return fileExtension;
  }
}
