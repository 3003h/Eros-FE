import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/setting/controller/eh_mysettings_controller.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:html_unescape/html_unescape.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

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

  static CacheOptions cacheOption = CacheOptions(
    store: BackupCacheStore(
      primary: MemCacheStore(),
      // secondary: HiveCacheStore(Global.tempPath),
      // secondary: FileCacheStore(Global.tempPath),
      secondary: BackupCacheStore(
        primary: HiveCacheStore(Global.tempPath),
        secondary: FileCacheStore(Global.tempPath),
      ),
    ),
    // store: MemCacheStore(),
    policy: CachePolicy.refresh,
    hitCacheOnErrorExcept: [401, 403, 503],
    maxStale: const Duration(days: 3),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  static String getBaseUrl({bool? isSiteEx}) {
    return EHConst.getBaseSite(
        isSiteEx ?? Get.find<EhSettingService>().isSiteEx.value);
  }

  static String getBaseHost({bool? isSiteEx}) {
    return EHConst.getBaseHost(
        isSiteEx ?? Get.find<EhSettingService>().isSiteEx.value);
  }

  static String getSiteFlg() {
    return (Get.find<EhSettingService>().isSiteEx.value) ? 'EH' : 'EX';
  }

  static _printCookie() async {
    final List<io.Cookie> _cookies =
        await (await cookieJar).loadForRequest(Uri.parse(getBaseUrl()));
    logger.t('${_cookies.map((e) => '$e').join('\n')} ');
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
    final List<List<String>> gidlist = <List<String>>[];

    for (final galleryProvider in galleryProviders) {
      if (galleryProvider.gid == null || galleryProvider.token == null) {
        continue;
      }
      if (galleryProvider.gid!.isEmpty || galleryProvider.token!.isEmpty) {
        continue;
      }
      gidlist.add([galleryProvider.gid!, galleryProvider.token!]);
    }

    // 25个一组分割
    List group = EHUtils.splitList(gidlist, 25);

    final resultList = <dynamic>[];

    // 查询 合并结果
    for (int i = 0; i < group.length; i++) {
      Map reqMap = {'gidlist': group[i], 'method': 'gdata'};
      final String reqJsonStr = jsonEncode(reqMap);
      logger.d('reqJsonStr $reqJsonStr');
      final result = await postEhApi(reqJsonStr);

      logger.d('result $result');

      final jsonObj = jsonDecode(result.toString());
      final tempList = jsonObj['gmetadata'] as List<dynamic>;
      resultList.addAll(tempList);
    }

    final HtmlUnescape unescape = HtmlUnescape();

    for (int i = 0; i < galleryProviders.length; i++) {
      // 标题
      final englishTitle = unescape.convert('${resultList[i]['title']}');

      // 日语标题
      final japaneseTitle = unescape.convert('${resultList[i]['title_jpn']}');

      // 详细评分
      final ratingStr = resultList[i]['rating'] as String?;
      final rating = ratingStr != null
          ? double.parse(ratingStr)
          : galleryProviders[i].ratingFallBack;

      // 封面图片
      final String thumb = resultList[i]['thumb'] as String;
      final imgUrlL = thumb;

      // 文件数量
      final fileCount = resultList[i]['filecount'] as String?;

      // 上传者
      final uploader = resultList[i]['uploader'] as String?;
      final category = resultList[i]['category'] as String?;

      // 标签
      final List<dynamic> tags = resultList[i]['tags'] as List<dynamic>;
      final tagsFromApi = tags;

      // 大小
      final filesize = resultList[i]['filesize'] as int?;

      // 种子数量
      final torrentcount = resultList[i]['torrentcount'] as String?;

      // 种子列表
      final List<dynamic> torrents = resultList[i]['torrents'] as List<dynamic>;
      final _torrents = <GalleryTorrent>[];
      for (final element in torrents) {
        _torrents.add(GalleryTorrent.fromJson(element as Map<String, dynamic>));
      }

      /// 判断获取语言标识
      String translated = '';
      if (tags.isNotEmpty) {
        translated = EHUtils.getLanguage(tags[0] as String);
      }

      galleryProviders[i] = galleryProviders[i].copyWith(
        englishTitle: englishTitle.oN,
        japaneseTitle: japaneseTitle.oN,
        rating: rating?.oN,
        imgUrlL: imgUrlL.oN,
        filecount: fileCount?.oN,
        uploader: uploader?.oN,
        category: category?.oN,
        tagsFromApi: tagsFromApi.oN,
        filesize: filesize?.oN,
        torrentcount: torrentcount?.oN,
        torrents: _torrents.oN,
        translated: translated.oN,
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
    if (!Get.find<EhSettingService>().autoSelectProfile) {
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
    const kProfileName = 'Eros-FE';

    final uconfig = await getEhSettings(refresh: true);

    final List<EhProfile> ehProfiles = uconfig?.profilelist ?? [];

    if (uconfig != null) {
      Get.find<EhMySettingsController>().ehSetting = uconfig;
    }

    final fepIndex =
        ehProfiles.indexWhere((element) => element.name.trim() == kProfileName);
    final bool existFEhProfile = fepIndex > -1;

    if (ehProfiles.isNotEmpty)
      logger.t('ehProfiles\n${ehProfiles.map((e) => e.toJson()).join('\n')} ');

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
        RegExp(r'(http?s://e([-x])hentai.org)?/g/(\d+)/(\w+)/?$');
    logger.d('>> galleryProvider.url ${galleryProvider.url}');
    final RegExpMatch? urlRult = urlRex.firstMatch(galleryProvider.url ?? '');
    // logger.t(urlRult.groupCount);

    final gid = urlRult?.group(3);
    final token = urlRult?.group(4);

    final GalleryProvider tempProvider =
        galleryProvider.copyWith(gid: gid?.oN, token: token?.oN);

    final List<GalleryProvider> reqGalleryItems = <GalleryProvider>[
      tempProvider
    ];

    return (await getMoreGalleryInfo(reqGalleryItems, refresh: refresh)).first;
  }

  // 从ExtendedImage缓存保存图片
  static Future<String?> saveImageFromExtendedCache({
    required String imageUrl,
    required String parentPath,
    required String fileNameWithoutExtension,
  }) async {
    if (!(await cachedImageExists(imageUrl))) {
      return null;
    }

    logger.d('fileNameWithoutExtension $fileNameWithoutExtension');

    final imageFile = await getCachedImageFile(imageUrl);
    if (imageFile == null) {
      logger.d('not from cache \n$imageUrl');
      return null;
    }

    logger.d('from cache \n$imageUrl');

    final bytes = await imageFile.readAsBytes();
    final mimeType =
        lookupMimeType(imageFile.path, headerBytes: bytes.take(8).toList());
    logger.d('mimeType $mimeType');
    final ext = mimeType?.split('/').last ?? 'jpg';
    final fileName = '$fileNameWithoutExtension.$ext';

    if (parentPath.isContentUri) {
      // SAF 方式

      // await safCreateDirectory(Uri.parse(parentPath));

      final result = await ss.createFileAsBytes(
        Uri.parse(parentPath),
        mimeType: mimeType ?? '',
        displayName: fileName,
        bytes: bytes,
      );
      logger.d('save to content:// result ${result?.uri}');
      return fileName;
    } else {
      // 普通方式
      final toFilePath = path.join(parentPath, fileName);
      final toFile = File(toFilePath);
      // write file
      await toFile.writeAsBytes(bytes);
      return toFilePath;
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

//    logger.t('$imageUrl');

    final GalleryImage _reImage = GalleryImage(
      imageUrl: imageUrl,
      ser: index + 1,
      imageWidth: width,
      imageHeight: height,
    );

    return _reImage;
  }

  // 下载单张图片
  static Future<String> _downloadImage(
    String imageUrl, {
    required String? gid,
    required int? ser,
    String? fileName,
    ProgressCallback? progressCallback,
  }) async {
    String? saveDir;
    io.File? saveFile;
    late String realSavePath;
    if (imageUrl.contains('/fullimg')) {
      saveDir = path.join(
          Global.tempPath, 'ori_image_temp', gid ?? '0', '${ser ?? 0}');
      if (!io.Directory(saveDir).existsSync()) {
        io.Directory(saveDir).createSync(recursive: true);
      }
    }

    final dir = io.Directory(saveDir ?? Global.tempPath);
    if (dir.existsSync()) {
      logger.d('缓存文件 ${dir.path}');
      dir.listSync().forEach((element) {
        logger.d('path ${element.path}');
        if (element is io.File) {
          saveFile = element;
          logger.d('读取缓存文件 ${saveFile?.path}');
        }
      });
    }

    if (saveFile == null) {
      await ehDownload(
          progressCallback: progressCallback,
          url: imageUrl,
          savePathBuilder: (Headers headers) {
            logger.d('headers:\n$headers');
            final contentDisposition = headers.value('content-disposition');
            logger.d('contentDisposition $contentDisposition');
            final filename = contentDisposition
                    ?.split(RegExp(r"filename(=|\*=UTF-8'')"))
                    .last ??
                '';
            final fileNameDecode =
                Uri.decodeFull(filename).replaceAll('/', '_');
            logger.d('fileNameDecode: $fileNameDecode, fileName: $fileName');
            if (fileNameDecode.isEmpty) {
              realSavePath = path.join(
                  saveDir ?? path.join(Global.tempPath, gid ?? '0'), fileName);
            } else {
              realSavePath = saveDir != null
                  ? path.join(saveDir, fileNameDecode)
                  : path.join(Global.tempPath, gid ?? '0', fileNameDecode);
            }

            return realSavePath;
          });
    } else {
      realSavePath = saveFile!.path;
    }

    return realSavePath;
  }

  // 保存图片到相册
  static Future<void> saveNetworkImageToPhoto(
    String imageUrl, {
    required String? gid,
    required int? ser,
    String? filename,
    ProgressCallback? progressCallback,
    BuildContext? context,
  }) async {
    logger.d('imageUrl $imageUrl');

    // 权限检查
    final permission =
        await requestPhotosPermission(context: context, addOnly: true);
    if (!permission) {
      throw EhError(error: 'Permission denied');
    }

    logger.d('开始下载图片');

    io.File? file;
    late String realFileName;
    bool isCached = false;

    // 从缓存中获取
    file = await getCachedImageFile(imageUrl);

    if (file != null) {
      isCached = true;
      realFileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
    } else {
      // 无缓存下载
      logger.d('无缓存下载');
      final savePath = await _downloadImage(
        imageUrl,
        gid: gid,
        ser: ser,
        fileName: filename,
        progressCallback: (count, total) {
          logger.t('count $count, total $total');
          progressCallback?.call(count, total);
        },
      );
      file = io.File(savePath);
      realFileName = path.basename(savePath);
    }

    realFileName = realFileName.replaceAll('/', '_');
    if (gid != null) {
      realFileName = '$gid-$realFileName';
    }
    logger.d('^^^^ 保存图片到相册 $realFileName lengthSync:${file.lengthSync()}');

    try {
      late final dynamic result;

      if (Platform.isAndroid || !isCached) {
        // Android 直接使用缓存路径的图片文件, 或者非缓存图片（通常为下载原图）
        result = await ImageGallerySaver.saveFile(
          file.path,
          name: realFileName,
        );
      } else {
        // iOS 不能直接使用缓存路径的图片文件， 所以需要先读取文件内容
        result = await ImageGallerySaver.saveImage(
          file.readAsBytesSync(),
          name: realFileName,
          quality: 100,
        );
      }

      logger.d('${result.runtimeType} $result');

      if (result == null || result == '') {
        throw EhError(error: 'Save image fail');
      }

      if (result is Map) {
        final isSuccess = result['isSuccess'] as bool;
        final errorMessage = result['errorMessage'] as String?;
        if (!isSuccess) {
          throw EhError(error: errorMessage ?? 'Save image fail');
        }
      }

      // final result = await ImageSave.saveImage(
      //   file.readAsBytesSync(),
      //   realFileName,
      //   albumName: EHConst.appTitle,
      //   overwriteSameNameFile: false,
      // );
      // if (result == null || !result) {
      //   throw EhError(error: 'Save image fail');
      // }
    } on EhError catch (e) {
      rethrow;
    } catch (e, s) {
      logger.e('保存图片到相册失败', error: e, stackTrace: s);
      throw EhError(error: '保存失败');
    }
  }

  static Future<void> shareNetworkImage(
    String imageUrl, {
    required String? gid,
    required int? ser,
    String? filename,
    ProgressCallback? progressCallback,
    BuildContext? context,
  }) async {
    logger.d('imageUrl $imageUrl');
    logger.d('开始下载图片');

    io.File? file;
    late String realFileName;

    // 从缓存中获取
    file = await getCachedImageFile(imageUrl);

    if (file != null) {
      realFileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
      logger.d('realFileName $realFileName');
      file = file.copySync(path.join(Global.tempPath, realFileName));
    } else {
      // 无缓存下载
      logger.d('无缓存下载');
      final realSavePath = await _downloadImage(
        imageUrl,
        gid: gid,
        ser: ser,
        fileName: filename,
        progressCallback: progressCallback,
      );
      logger.d('realSavePath $realSavePath');
      file = io.File(realSavePath);

      realFileName = path.basename(file.path);
    }

    realFileName = realFileName.replaceAll('/', '_');
    if (gid != null) {
      realFileName = '$gid-$realFileName';
    }

    await Share.shareXFiles([XFile(file.path)], subject: realFileName);
  }

  // 保存本地图片到相册
  static Future<void> saveLocalImageToPhoto(
    String imagePath, {
    String? gid,
    ProgressCallback? progressCallback,
    BuildContext? context,
  }) async {
    // 权限检查
    final permission =
        await requestPhotosPermission(context: context, addOnly: true);
    if (!permission) {
      throw EhError(error: 'Permission denied');
    }

    final file = io.File(imagePath);
    if (!file.existsSync()) {
      throw EhError(error: 'File not found');
    }

    final result = await ImageGallerySaver.saveFile(file.path);
    logger.d('${result.runtimeType} $result');

    if (result == null || result == '') {
      throw EhError(error: 'Save image fail');
    }
  }

  static Future<void> shareLocalImage(
    String imagePath, {
    String? gid,
    ProgressCallback? progressCallback,
    BuildContext? context,
  }) async {
    final file = io.File(imagePath);
    if (!file.existsSync()) {
      throw EhError(error: 'File not found');
    }

    await Share.shareXFiles([XFile(imagePath)]);
  }
}
