import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/parser/eh_parser.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/foundation.dart';

import '../request.dart';
import 'exception.dart';
import 'http_response.dart';

typedef HttpTransformerBuilderCallback = FutureOr<DioHttpResponse> Function(
    Response response);

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
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  DefaultHttpTransformer._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory DefaultHttpTransformer.getInstance() => _instance;

  /// 单例对象
  static final DefaultHttpTransformer _instance =
      DefaultHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<dynamic>> parse(Response response) {
    // if (response.data["code"] == 100) {
    //   return HttpResponse.success(response.data["data"]);
    // } else {
    // return HttpResponse.failure(errorMsg:response.data["message"],errorCode: response.data["code"]);
    // }
    // return DioHttpResponse.success(response.data['data']);
    return DioHttpResponse.success(response.data);
  }
}

class HttpTransformerBuilder extends HttpTransformer {
  HttpTransformerBuilder(this.parseCallback);

  final HttpTransformerBuilderCallback parseCallback;

  @override
  FutureOr<DioHttpResponse> parse(Response<dynamic> response) {
    return parseCallback(response);
  }
}

/// 画廊列表解析
class GalleryListHttpTransformer extends HttpTransformer {
  factory GalleryListHttpTransformer() => _instance;
  GalleryListHttpTransformer._internal();
  static late final GalleryListHttpTransformer _instance =
      GalleryListHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<GalleryList>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;

    // 列表样式检查 不符合则设置参数重新请求
    final bool isDml = isGalleryListDmL(html);
    if (isDml) {
      // final GalleryList _list = await compute(parseGalleryList, html);
      final GalleryList _list = parseGalleryList(html);

      // 查询和写入simpletag的翻译
      final _listWithTagTranslate = await _list.qrySimpleTagTranslate;

      return DioHttpResponse<GalleryList>.success(_listWithTagTranslate);
    } else {
      return DioHttpResponse<GalleryList>.failureFromError(
          ListDisplayModeException());
    }
  }
}

/// 画廊列表解析 - 收藏夹页
class FavoriteListHttpTransformer extends HttpTransformer {
  factory FavoriteListHttpTransformer() => _instance;
  FavoriteListHttpTransformer._internal();
  static late final FavoriteListHttpTransformer _instance =
      FavoriteListHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<GalleryList>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;

    // 排序方式检查
    final FavoriteOrder order = EnumToString.fromString(
            FavoriteOrder.values, Global.profile.ehConfig.favoritesOrder) ??
        FavoriteOrder.fav;
    // 排序参数
    final String _order = EHConst.favoriteOrder[order] ?? EHConst.FAV_ORDER_FAV;
    // final bool isOrderFav = isFavoriteOrder(html);
    final bool isOrderFav = await compute(isFavoriteOrder, html);

    final bool needReOrder = isOrderFav ^ (order == FavoriteOrder.fav);

    // 列表样式检查 不符合则设置参数重新请求
    // final bool isDml = isGalleryListDmL(html);
    final bool isDml = await compute(isGalleryListDmL, html);

    if (!isDml) {
      return DioHttpResponse<GalleryList>.failureFromError(
          ListDisplayModeException());
    } else if (needReOrder) {
      return DioHttpResponse<GalleryList>.failureFromError(
          FavOrderException(order: _order));
    } else {
      // final GalleryList _list = await compute(parseGalleryListOfFav, html);
      final GalleryList _list = parseGalleryListOfFav(html);

      // 查询和写入simpletag的翻译
      final _listWithTagTranslate = await _list.qrySimpleTagTranslate;

      return DioHttpResponse<GalleryList>.success(_listWithTagTranslate);
    }
  }
}

/// 画廊解析
class GalleryHttpTransformer extends HttpTransformer {
  factory GalleryHttpTransformer() => _instance;
  GalleryHttpTransformer._internal();
  static late final GalleryHttpTransformer _instance =
      GalleryHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<GalleryProvider>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final GalleryProvider provider = await parseGalleryDetail(html);
    return DioHttpResponse<GalleryProvider>.success(provider);
  }
}

class GalleryImageHttpTransformer extends HttpTransformer {
  factory GalleryImageHttpTransformer() => _instance;
  GalleryImageHttpTransformer._internal();
  static late final GalleryImageHttpTransformer _instance =
      GalleryImageHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<GalleryImage>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    // 使用 compute 方式会内部的 EhError 无法正常抛出
    final GalleryImage image = await compute(paraImage, html);
    // throw EhError(type: EhErrorType.image509);
    if (image.imageUrl!.endsWith('/509.gif') ||
        image.imageUrl!.endsWith('/509s.gif')) {
      throw EhError(type: EhErrorType.image509);
    }
    // final GalleryImage image = await paraImage(html);
    return DioHttpResponse<GalleryImage>.success(image);
  }
}

class GalleryMpvImageHttpTransformer extends HttpTransformer {
  GalleryMpvImageHttpTransformer(this.ser, {this.sourceId});

  final String ser;
  final String? sourceId;

  @override
  FutureOr<DioHttpResponse<GalleryImage>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final mpvPage = await compute(parserMpvPage, html);

    if (mpvPage.mpvkey == null || mpvPage.mpvkey!.isEmpty) {
      return DioHttpResponse<GalleryImage>.failure(
          errorMsg: 'get mpvkey empty');
    }

    if (mpvPage.gid == 0) {
      return DioHttpResponse<GalleryImage>.failure(errorMsg: 'get gid empty');
    }

    final _page = int.parse(ser);
    final mpvImage = mpvPage.imagelist?[_page - 1];
    if (mpvImage == null) {
      return DioHttpResponse<GalleryImage>.failure(
          errorMsg: 'get mpvImage empty or null');
    }

    if (mpvImage.k == null || mpvImage.k!.isEmpty) {
      return DioHttpResponse<GalleryImage>.failure(
          errorMsg: 'imagekey of $_page is empty or null');
    }

    // 请求 api 获取大图信息
    final galleryImage = await mpvLoadImageDispatch(
      gid: mpvPage.gid!,
      mpvkey: mpvPage.mpvkey!,
      page: _page,
      imgkey: mpvImage.k!,
      sourceId: sourceId,
    );

    return DioHttpResponse<GalleryImage>.success(galleryImage);
  }
}

class GalleryImageListHttpTransformer extends HttpTransformer {
  factory GalleryImageListHttpTransformer() => _instance;
  GalleryImageListHttpTransformer._internal();
  static late final GalleryImageListHttpTransformer _instance =
      GalleryImageListHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<List<GalleryImage>>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    // final List<GalleryImage> image = parseGalleryImageFromHtml(html);
    final List<GalleryImage> image =
        await compute(parseGalleryImageFromHtml, html);

    return DioHttpResponse<List<GalleryImage>>.success(image);
  }
}

// class GalleryArchiverHttpTransformer extends HttpTransformer {
//   factory GalleryArchiverHttpTransformer() => _instance;
//   GalleryArchiverHttpTransformer._internal();
//   static late final GalleryArchiverHttpTransformer _instance =
//       GalleryArchiverHttpTransformer._internal();
//
//   @override
//   FutureOr<DioHttpResponse<ArchiverProvider>> parse(
//       Response<dynamic> response) async {
//     final html = response.data as String;
//     final ArchiverProvider archiverProvider = parseArchiver(html);
//     return DioHttpResponse<ArchiverProvider>.success(archiverProvider);
//   }
// }

class GalleryArchiverRemoteDownloadResponseTransformer extends HttpTransformer {
  factory GalleryArchiverRemoteDownloadResponseTransformer() => _instance;
  GalleryArchiverRemoteDownloadResponseTransformer._internal();
  static late final GalleryArchiverRemoteDownloadResponseTransformer _instance =
      GalleryArchiverRemoteDownloadResponseTransformer._internal();

  @override
  FutureOr<DioHttpResponse<String>> parse(Response<dynamic> response) async {
    final html = response.data as String;
    final String msg = parseArchiverDownload(html);
    return DioHttpResponse<String>.success(msg);
  }
}

class GalleryArchiverLocalDownloadResponseTransformer extends HttpTransformer {
  factory GalleryArchiverLocalDownloadResponseTransformer() => _instance;
  GalleryArchiverLocalDownloadResponseTransformer._internal();
  static late final GalleryArchiverLocalDownloadResponseTransformer _instance =
      GalleryArchiverLocalDownloadResponseTransformer._internal();

  @override
  FutureOr<DioHttpResponse<String>> parse(Response<dynamic> response) async {
    final html = response.data as String;
    final String _href =
        RegExp(r'document.location = "(.+)"').firstMatch(html)?.group(1) ?? '';
    return DioHttpResponse<String>.success('$_href?start=1');
  }
}

class UconfigHttpTransformer extends HttpTransformer {
  factory UconfigHttpTransformer() => _instance;
  UconfigHttpTransformer._internal();
  static late final UconfigHttpTransformer _instance =
      UconfigHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<EhSettings>> parse(
      Response<dynamic> response) async {
    final html = response.data as String;
    final EhSettings uconfig = await compute(parseEhSettings, html);
    return DioHttpResponse<EhSettings>.success(uconfig);
  }
}

class MyTagsHttpTransformer extends HttpTransformer {
  factory MyTagsHttpTransformer() => _instance;
  MyTagsHttpTransformer._internal();
  static late final MyTagsHttpTransformer _instance =
      MyTagsHttpTransformer._internal();

  @override
  FutureOr<DioHttpResponse<EhMytags>> parse(Response<dynamic> response) async {
    final html = response.data as String;
    final EhMytags mytags = await parseMyTags(html);
    // 查询翻译
    final userTags = await mytags.qryFullTagTranslate;
    return DioHttpResponse<EhMytags>.success(
        mytags.copyWith(usertags: userTags));
  }
}

class ImageDispatchTransformer extends HttpTransformer {
  factory ImageDispatchTransformer() => _instance;
  ImageDispatchTransformer._internal();
  static late final ImageDispatchTransformer _instance =
      ImageDispatchTransformer._internal();

  @override
  FutureOr<DioHttpResponse<GalleryImage>> parse(
      Response<dynamic> response) async {
    final json = response.data as String;
    final GalleryImage image = await compute(parserMpvImageDispatch, json);
    return DioHttpResponse<GalleryImage>.success(image);
  }
}

class UserLoginTransformer extends HttpTransformer {
  factory UserLoginTransformer() => _instance;
  UserLoginTransformer._internal();
  static late final UserLoginTransformer _instance =
      UserLoginTransformer._internal();

  @override
  FutureOr<DioHttpResponse<User>> parse(Response<dynamic> response) async {
    final List<String> setcookie = response.headers['set-cookie'] ?? [];
    logger.d('setcookie: $setcookie');

    final _cookies =
        setcookie.map((str) => Cookie.fromSetCookieValue(str)).toList();

    final cookieStr =
        _cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');

    logger.d('cookieStr: $cookieStr');

    final Map<String, String> cookieMap = <String, String>{};
    for (final Cookie cookie in _cookies) {
      cookieMap[cookie.name] = cookie.value;
    }

    final User user = kDefUser.copyWith(
      memberId: cookieMap['ipb_member_id'],
      passHash: cookieMap['ipb_pass_hash'],
      igneous: cookieMap['igneous'],
      hathPerks: cookieMap['hath_perks'],
      sk: cookieMap['sk'],
    );
    return DioHttpResponse<User>.success(user);
  }
}

class UserInfoPageTransformer extends HttpTransformer {
  factory UserInfoPageTransformer() => _instance;
  UserInfoPageTransformer._internal();
  static late final UserInfoPageTransformer _instance =
      UserInfoPageTransformer._internal();

  @override
  FutureOr<DioHttpResponse<User>> parse(Response<dynamic> response) async {
    final html = response.data as String;
    final User user = await compute(parseUserProfile, html);

    logger.v('UserInfoPageTransformer user ${user.toJson()}');

    return DioHttpResponse<User>.success(user);
  }
}

class PostCommentTransformer extends HttpTransformer {
  @override
  FutureOr<DioHttpResponse<bool>> parse(Response<dynamic> response) {
    return DioHttpResponse<bool>.success(response.statusCode == 302);
  }
}

class TagActionTransformer extends HttpTransformer {
  @override
  FutureOr<DioHttpResponse<bool>> parse(Response<dynamic> response) {
    return DioHttpResponse<bool>.success(response.statusCode == 302);
  }
}
