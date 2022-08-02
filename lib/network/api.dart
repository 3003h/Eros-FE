import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/setting/controller/eh_mysettings_controller.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:html_unescape/html_unescape.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

final Api api = Api();

enum ProfileOpType {
  create,
  select,
  delete,
}

// ignore: avoid_classes_with_only_static_members
class Api {
  static PersistCookieJar? _cookieJar;

  static Future<PersistCookieJar> get cookieJar async {
    _cookieJar ??=
        PersistCookieJar(storage: FileStorage(Global.appSupportPath));
    return _cookieJar!;
  }

  static String getBaseUrl({bool? isSiteEx}) {
    return EHConst.getBaseSite(
        isSiteEx ?? Get.find<EhConfigService>().isSiteEx.value);
  }

  static String getBaseHost({bool? isSiteEx}) {
    return EHConst.getBaseHost(
        isSiteEx ?? Get.find<EhConfigService>().isSiteEx.value);
  }

  static String getSiteFlg() {
    return (Get.find<EhConfigService>().isSiteEx.value) ? 'EH' : 'EX';
  }

  static _printCookie() async {
    final List<io.Cookie> _cookies =
        await (await cookieJar).loadForRequest(Uri.parse(getBaseUrl()));
    logger.v('${_cookies.map((e) => '$e').join('\n')} ');
  }

  /// 通过api请求获取更多信息
  /// 例如
  /// 画廊评分
  /// 日语标题
  /// 等等
  static Future<List<GalleryProvider>> getMoreGalleryInfo(
    List<GalleryProvider> galleryProviders, {
    bool refresh = false,
  }) async {
    // logger.i('api qry items ${galleryProviders.length}');
    if (galleryProviders.isEmpty) {
      return galleryProviders;
    }

    // 通过api获取画廊详细信息
    final List<List<String>> _gidlist = <List<String>>[];

    galleryProviders.forEach((GalleryProvider galleryProvider) {
      _gidlist.add([galleryProvider.gid!, galleryProvider.token!]);
    });

    // 25个一组分割
    List _group = EHUtils.splitList(_gidlist, 25);

    final rultList = <dynamic>[];

    // 查询 合并结果
    for (int i = 0; i < _group.length; i++) {
      Map reqMap = {'gidlist': _group[i], 'method': 'gdata'};
      final String reqJsonStr = jsonEncode(reqMap);

      final rult = await postEhApi(reqJsonStr);

      final jsonObj = jsonDecode(rult.toString());
      final tempList = jsonObj['gmetadata'] as List<dynamic>;
      rultList.addAll(tempList);
    }

    final HtmlUnescape unescape = HtmlUnescape();

    for (int i = 0; i < galleryProviders.length; i++) {
      // 标题
      final _englishTitle = unescape.convert(rultList[i]['title'] as String);

      // 日语标题
      final _japaneseTitle =
          unescape.convert(rultList[i]['title_jpn'] as String);

      // 详细评分
      final rating = rultList[i]['rating'] as String?;
      final _rating = rating != null
          ? double.parse(rating)
          : galleryProviders[i].ratingFallBack;

      // 封面图片
      final String thumb = rultList[i]['thumb'] as String;
      final _imgUrlL = thumb;

      // 文件数量
      final _filecount = rultList[i]['filecount'] as String?;

      // logger.d('_filecount $_filecount');

      // 上传者
      final _uploader = rultList[i]['uploader'] as String?;
      final _category = rultList[i]['category'] as String?;

      // 标签
      final List<dynamic> tags = rultList[i]['tags'] as List<dynamic>;
      final _tagsFromApi = tags;

      // 大小
      final _filesize = rultList[i]['filesize'] as int?;

      // 种子数量
      final _torrentcount = rultList[i]['torrentcount'] as String?;

      // 种子列表
      final List<dynamic> torrents = rultList[i]['torrents'] as List<dynamic>;
      final _torrents = <GalleryTorrent>[];
      torrents.forEach((dynamic element) {
        // final Map<String, dynamic> e = element as Map<String, dynamic>;
        _torrents.add(GalleryTorrent.fromJson(element as Map<String, dynamic>));
      });

      /// 判断获取语言标识
      String _translated = '';
      if (tags.isNotEmpty) {
        _translated = EHUtils.getLangeage(tags[0] as String);
      }

      galleryProviders[i] = galleryProviders[i].copyWith(
        englishTitle: _englishTitle,
        japaneseTitle: _japaneseTitle,
        rating: _rating,
        imgUrlL: _imgUrlL,
        filecount: _filecount,
        uploader: _uploader,
        category: _category,
        tagsFromApi: _tagsFromApi,
        filesize: _filesize,
        torrentcount: _torrentcount,
        torrents: _torrents,
        translated: _translated,
      );
    }

    return galleryProviders;
  }

  /// 画廊评分
  static Future<Map<String, dynamic>> setRating({
    required String apikey,
    required String apiuid,
    required String gid,
    required String token,
    required int rating,
  }) async {
    final Map reqMap = {
      'apikey': apikey,
      'method': 'rategallery',
      'apiuid': int.parse(apiuid),
      'gid': int.parse(gid),
      'token': token,
      'rating': rating,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    logger.d('$reqJsonStr');
    final rult = await postEhApi(reqJsonStr);
    // logger.d('$rult');
    final Map<String, dynamic> rultMap =
        jsonDecode(rult.toString()) as Map<String, dynamic>;
    return rultMap;
  }

  static Future<CommitVoteRes> commitVote({
    required String apikey,
    required String apiuid,
    required String gid,
    required String token,
    required String commentId,
    required int vote,
  }) async {
    final Map reqMap = {
      'method': 'votecomment',
      'apikey': apikey,
      'apiuid': int.parse(apiuid),
      'gid': int.parse(gid),
      'token': token,
      'comment_id': int.parse(commentId),
      'comment_vote': vote,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    final rult = await postEhApi(reqJsonStr);
    return CommitVoteRes.fromJson(
        jsonDecode(rult.toString()) as Map<String, dynamic>);
  }

  /// 给画廊添加tag
  static Future<Map<String, dynamic>> tagGallery({
    required String apikey,
    required String apiuid,
    required String gid,
    required String token,
    String? tags,
    int vote = 1,
  }) async {
    final Map reqMap = {
      'apikey': apikey,
      'method': 'taggallery',
      'apiuid': int.parse(apiuid),
      'gid': int.parse(gid),
      'token': token,
      'tags': tags,
      'vote': vote,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    final rult = await postEhApi(reqJsonStr);
    logger.d('$rult');
    final Map<String, dynamic> rultMap =
        jsonDecode(rult.toString()) as Map<String, dynamic>;
    return rultMap;
  }

  /// 搜索匹配tag
  static Future<List<TagTranslat>> tagSuggest({
    required String text,
  }) async {
    final Map reqMap = {
      'method': 'tagsuggest',
      'text': text,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    final rult = await postEhApi(reqJsonStr);
    final Map<String, dynamic> rultMap =
        jsonDecode(rult.toString()) as Map<String, dynamic>;

    final Map<String, dynamic> tagMap = rultMap['tags'] is Map<String, dynamic>
        ? rultMap['tags'] as Map<String, dynamic>
        : {};
    final List<Map<String, dynamic>> rultList =
        tagMap.values.map((e) => e as Map<String, dynamic>).toList();

    List<TagTranslat> tagTranslateList = rultList
        .map((e) =>
            TagTranslat(namespace: e['ns'] as String, key: e['tn'] as String))
        .toList();

    return tagTranslateList;
  }

  // 保存用户tag
  static Future<Map<String, dynamic>> setUserTag({
    required String apikey,
    required String apiuid,
    required String tagid,
    bool tagWatch = false,
    bool tagHide = false,
    String? tagColor,
    String? tagWeight,
  }) async {
    final Map reqMap = {
      'method': 'setusertag',
      'apiuid': int.parse(apiuid),
      'apikey': apikey,
      'tagid': int.parse(tagid),
      'tagwatch': tagWatch ? 1 : 0,
      'taghide': tagHide ? 1 : 0,
      'tagcolor': tagColor ?? '',
      'tagweight': tagWeight,
    };
    final String reqJsonStr = jsonEncode(reqMap);
    final rult = await postEhApi(reqJsonStr);
    logger.d('$rult');
    final Map<String, dynamic> rultMap =
        jsonDecode(rult.toString()) as Map<String, dynamic>;
    return rultMap;
  }

  //
  static Future<bool?> selEhProfile() async {
    if (!Get.find<EhConfigService>().autoSelectProfile) {
      logger.d('do not to select profile');
      return null;
    }
    const int kRetry = 3;
    for (int i = 0; i < kRetry; i++) {
      final bool? rult = await _selEhProfile();
      // 创建或者选择完成
      if (rult != null && rult) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 2000));
    }
    return null;
  }

  /// 选用feh单独的profile 没有就新建
  static Future<bool?> _selEhProfile() async {
    // 不能带_
    const kProfileName = 'FEhViewer';

    final uconfig = await getEhSettings(refresh: true);

    final List<EhProfile> ehProfiles = uconfig?.profilelist ?? [];

    if (uconfig != null) {
      Get.find<EhMySettingsController>().ehSetting = uconfig;
    }

    final fepIndex =
        ehProfiles.indexWhere((element) => element.name.trim() == kProfileName);
    final bool existFEhProfile = fepIndex > -1;

    if (ehProfiles.isNotEmpty)
      logger.v('ehProfiles\n${ehProfiles.map((e) => e.toJson()).join('\n')} ');

    if (existFEhProfile) {
      // 存在名称为 FEhViewer 的配置
      final selectedSP =
          ehProfiles.firstWhereOrNull((element) => element.selected);
      if (selectedSP?.name == kProfileName) {
        return true;
      }
      logger.d(
          'exist profile name [$kProfileName] but not selected, select it...');
      final fEhProfile = ehProfiles[fepIndex];
      await cleanCookie('sp');
      // await operatorProfile(type: ProfileOpType.select, set: fEhProfile.value);
      await changeEhProfile('${fEhProfile.value}');
      return true;
    } else if (ehProfiles.isNotEmpty) {
      // create 完成后会自动set_cookie sp为新建的sp
      logger.d('create new profile');
      await createEhProfile(kProfileName);
      return true;
    }
    return null;
  }

  static Future<GalleryProvider> getMoreGalleryInfoOne(
    GalleryProvider galleryProvider, {
    bool refresh = false,
  }) async {
    final RegExp urlRex =
        RegExp(r'(http?s://e(-|x)hentai.org)?/g/(\d+)/(\w+)/?$');
    // logger.v(galleryProvider.url);
    final RegExpMatch? urlRult = urlRex.firstMatch(galleryProvider.url ?? '');
    // logger.v(urlRult.groupCount);

    final String gid = urlRult?.group(3) ?? '';
    final String token = urlRult?.group(4) ?? '';

    final GalleryProvider tempProvider =
        galleryProvider.copyWith(gid: gid, token: token);

    final List<GalleryProvider> reqGalleryItems = <GalleryProvider>[
      tempProvider
    ];

    return (await getMoreGalleryInfo(reqGalleryItems, refresh: refresh)).first;
  }

  static Future<void> shareImageExtended({
    String? imageUrl,
    String? filePath,
  }) async {
    if (imageUrl == null && filePath == null) {
      return;
    }

    logger.d('imageUrl:$imageUrl   filePath:$filePath');

    io.File? file;
    String? _name;

    if (filePath != null) {
      file = io.File(filePath);
      _name = path.basename(filePath);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      logger.d('imageUrl => $imageUrl');
      final exists = await cachedImageExists(imageUrl);
      file = await getCachedImageFile(imageUrl);
      logger.d('exists $exists');
      if (!exists || file == null) {
        try {
          file = await imageCacheManager.getSingleFile(imageUrl,
              headers: {'cookie': Global.profile.user.cookie});
        } catch (e, stack) {
          logger.e('$e\n$stack');
          throw 'get file error';
        }
      }
      _name = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
    }

    if (file == null) {
      throw 'get file error';
    }

    logger.v('_name $_name url $imageUrl');
    final io.File newFile = file.copySync(path.join(Global.tempPath, _name));
    Share.shareFiles(<String>[newFile.path]);
  }

  /// 保存图片到相册
  static Future<bool> saveImage({
    BuildContext? context,
    String? imageUrl,
    String? filePath,
  }) async {
    /// 跳转权限设置
    Future<bool?> _jumpToAppSettings(BuildContext context) async {
      return await jumpToAppSettings(
          context,
          'You have disabled the necessary permissions for the application:'
          '\nRead and write phone storage, is it allowed in the settings?');
    }

    if (io.Platform.isIOS) {
      logger.v('check ios photos Permission');
      final PermissionStatus statusPhotos = await Permission.photos.status;
      final PermissionStatus statusPhotosAdd =
          await Permission.photosAddOnly.status;

      logger.d('statusPhotos $statusPhotos , photosAddOnly $statusPhotosAdd');

      if (statusPhotos.isPermanentlyDenied &&
          statusPhotosAdd.isPermanentlyDenied &&
          context != null) {
        _jumpToAppSettings(context);
        return false;
      } else {
        final requestAddOnly =
            () async => await Permission.photosAddOnly.request();
        final requestAll = () async => await Permission.photos.request();

        if (await requestAddOnly().isGranted ||
            await requestAddOnly().isLimited ||
            await requestAll().isGranted ||
            await requestAll().isLimited) {
          // return _saveImage(imageUrl);
          return _saveImageExtended(imageUrl: imageUrl, filePath: filePath);
          // Either the permission was already granted before or the user just granted it.
        } else {
          throw 'Unable to save pictures, please authorize first~';
        }
      }
    } else {
      final PermissionStatus status = await Permission.storage.status;
      logger.v(status);
      if (status.isPermanentlyDenied) {
        if (await Permission.storage.request().isGranted) {
          // _saveImage(imageUrl);
          return _saveImageExtended(imageUrl: imageUrl, filePath: filePath);
        } else if (context != null) {
          await _jumpToAppSettings(context);
          return false;
        }
        return false;
      } else {
        if (await Permission.storage.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          // return _saveImage(imageUrl);
          return _saveImageExtended(imageUrl: imageUrl, filePath: filePath);
        } else {
          throw 'Unable to save pictures, please authorize first~';
        }
      }
    }
  }

  static Future<bool> saveImageFromExtendedCache({
    required String imageUrl,
    required String savePath,
  }) async {
    if (!(await cachedImageExists(imageUrl))) {
      return false;
    }

    final imageFile = await getCachedImageFile(imageUrl);
    if (imageFile == null) {
      logger.d('not from cache \n$imageUrl');
      return false;
    }

    logger.d('from cache \n$imageUrl');

    // final imageBytes = await imageFile.readAsBytes();
    // final _name = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);

    final destFile = imageFile.copySync(savePath);
    return true;
  }

  static Future<bool> _saveImageExtended({
    String? imageUrl,
    String? filePath,
  }) async {
    try {
      if (imageUrl == null && filePath == null) {
        throw 'Save failed, picture does not exist!';
      }

      /// 保存的图片数据
      Uint8List imageBytes;
      io.File? file;
      String? _name;

      if (filePath != null) {
        file = io.File(filePath);
        if (!file.existsSync()) {
          throw 'read file error';
        }
        imageBytes = await file.readAsBytes();
        _name = path.basename(filePath);
      } else if (imageUrl != null) {
        /// 保存网络图片
        logger.d('保存网络图片');
        file = await getCachedImageFile(imageUrl);

        if (file == null) {
          throw 'read file error';
        }

        logger.v('file path ${file.path}');

        // imageBytes = await file.readAsBytes();

        _name = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
        logger.v('_name $_name url $imageUrl');
      }

      if (file == null) {
        throw 'read file error';
      }

      final io.File newFile = file.copySync(path.join(Global.tempPath, _name));
      logger.v('${newFile.path} ${file.lengthSync()} ${newFile.lengthSync()}');

      final result = await ImageGallerySaver.saveFile(newFile.path);

      if (result == null || result == '') {
        throw 'Save image fail';
      }

      logger.d('保存成功');
      return true;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }

  /// 由api获取画廊图片的信息
  /// [href] 爬取的页面地址 用来解析gid 和 imgkey
  /// [showKey] api必须
  /// [index] 索引 从 1 开始
  static Future<GalleryImage> paraImageLageInfoFromApi(
    String href,
    String showKey, {
    required int index,
  }) async {
    const String url = '/api.php';

    final String cookie = Global.profile.user.cookie;

    final dio.Options options = dio.Options(headers: {
      'Cookie': cookie,
    });

    final RegExp regExp =
        RegExp(r'https://e[-x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
    final RegExpMatch? regRult = regExp.firstMatch(href);
    final int gid = int.parse(regRult?.group(2) ?? '0');
    final String imgkey = regRult?.group(1) ?? '';
    final int page = int.parse(regRult?.group(3) ?? '0');

    final Map<String, Object> reqMap = {
      'method': 'showpage',
      'gid': gid,
      'page': page,
      'imgkey': imgkey,
      'showkey': showKey,
    };
    final String reqJsonStr = jsonEncode(reqMap);

    final response = await postEhApi(reqJsonStr);

    final dynamic rultJson = jsonDecode('$response');

    final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
    final String imageUrl =
        regImageUrl.firstMatch(rultJson['i3'] as String)?.group(1) ?? '';
    final double width = double.parse(rultJson['x'].toString());
    final double height = double.parse(rultJson['y'].toString());

//    logger.v('$imageUrl');

    final GalleryImage _reImage = GalleryImage(
      imageUrl: imageUrl,
      ser: index + 1,
      imageWidth: width,
      imageHeight: height,
    );

    return _reImage;
  }
}
