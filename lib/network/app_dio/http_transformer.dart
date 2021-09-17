import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/parser/eh_parser.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/logger.dart';

import 'http_response.dart';

/// Response 解析
abstract class HttpTransformer {
  FutureOr<DioHttpResponse<dynamic>> parse(Response response);
}

class DefaultHttpTransformer extends HttpTransformer {
// 假设接口返回类型
//   {
//     "code": 100,
//     "data": {},
//     "message": "success"
// }
  @override
  FutureOr<DioHttpResponse<dynamic>> parse(Response response) {
    // if (response.data["code"] == 100) {
    //   return HttpResponse.success(response.data["data"]);
    // } else {
    // return HttpResponse.failure(errorMsg:response.data["message"],errorCode: response.data["code"]);
    // }
    return DioHttpResponse.success(response.data['data']);
  }

  /// 单例对象
  static DefaultHttpTransformer _instance = DefaultHttpTransformer._internal();

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  DefaultHttpTransformer._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory DefaultHttpTransformer.getInstance() => _instance;
}

/// 画廊列表解析
class GalleryListHttpTransformer extends HttpTransformer {
  @override
  FutureOr<DioHttpResponse<GallerysAndMaxpage>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final GallerysAndMaxpage gam = await parseGalleryList(html);
    return DioHttpResponse<GallerysAndMaxpage>.success(gam);
  }
}

/// 画廊列表解析 - 收藏夹页
class FavoriteListHttpTransformer extends HttpTransformer {
  @override
  FutureOr<DioHttpResponse<GallerysAndMaxpage>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final GallerysAndMaxpage gam =
        await parseGalleryList(html, isFavorite: true);
    return DioHttpResponse<GallerysAndMaxpage>.success(gam);
  }
}

/// 画廊解析
class GalleryHttpTransformer extends HttpTransformer {
  @override
  FutureOr<DioHttpResponse<GalleryItem>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final GalleryItem item = await parseGalleryDetail(html);
    return DioHttpResponse<GalleryItem>.success(item);
  }
}

class GalleryImageHttpTransformer extends HttpTransformer {
  @override
  FutureOr<DioHttpResponse<GalleryImage>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final GalleryImage image = await paraImage(html);
    return DioHttpResponse<GalleryImage>.success(image);
  }
}
