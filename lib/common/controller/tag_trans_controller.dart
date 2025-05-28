import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../global.dart';

const String kApiUrl =
    'https://api.github.com/repos/EhTagTranslation/Database/releases/latest';
const String kCDNApiUrl =
    'https://ghproxy.homeboyc.cn/https://api.github.com/repos/EhTagTranslation/Database/releases/latest';
const String kCDNPrefix = 'https://ghproxy.homeboyc.cn/';
const int kConnectTimeout = 20000;
const int kReceiveTimeout = 30000;

class TagTransController extends GetxController {
  final EhSettingService ehSettingService = Get.find();

  String? _dbUrl;
  String? _remoteVer;

  List<String?> _namespaces = [];

  @override
  void onInit() {
    super.onInit();
    getNamespace().then((value) {
      logger.d('getNamespace $value');
      return _namespaces = value;
    });
  }

  Future<List<String?>> getNamespace() async {
    return await isarHelper.findAllTagNamespace();
  }

  /// 检查更新
  Future<bool> checkUpdate({bool force = false}) async {
    late final String apiUrl;
    if (ehSettingService.enableTagTranslateCDN) {
      apiUrl = kCDNApiUrl;
    } else {
      apiUrl = kApiUrl;
    }

    final urlJson = await getGithubApi(apiUrl);

    final publishedTime = '${urlJson['published_at']}';
    final tagName = '${urlJson['tag_name']}';

    // 远程版本号
    _remoteVer = '$tagName $publishedTime';

    // 获取当前本地版本
    final String localVer = ehSettingService.tagTranslatVer.value;

    logger.d('localVer $localVer, remoteVer $_remoteVer');

    if (_remoteVer == localVer && force == false) {
      logger.d('tagTranslateVer is latest');
      return false;
    }

    final List<dynamic> assList = urlJson['assets'] as List<dynamic>;
    final Map<String, String> assMap = <String, String>{};
    for (final dynamic assets in assList) {
      assMap[assets['name'] as String? ?? ''] =
          assets['browser_download_url'] as String;
    }
    _dbUrl = assMap['db.raw.json.gz'] ?? '';

    if (ehSettingService.enableTagTranslateCDN) {
      _dbUrl = '$kCDNPrefix$_dbUrl';
    }

    logger.d(_dbUrl);
    return true;
  }

  /// 获取数据
  Future<List> _fetchData({bool silence = false}) async {
    logger.t('_fetchData start');

    if (_dbUrl == null) {
      return [];
    }

    final gzFilePath = path.join(Global.appDocPath, 'db.raw.json.gz');
    await ehDownload(url: _dbUrl!, savePath: gzFilePath);
    List<int> bytes = File(gzFilePath).readAsBytesSync();
    List<int> data = GZipDecoder().decodeBytes(bytes);
    final String dbJson = utf8.decode(data);

    final dbDataMap = jsonDecode(dbJson);
    final List listData = dbDataMap['data'] as List;

    // final head = dbDataMap['head'] as Map;
    // final committer = head['committer'] as Map;

    // _remoteVer = committer['when'] as String;
    // logger.d('_remoteVer $_remoteVer');

    return listData;
  }

  /// 更新数据库数据
  Future<void> updateDB({bool silence = false}) async {
    List listData = await _fetchData();
    if (listData.isEmpty) {
      return;
    }

    final List<TagTranslat> tagTranslats = <TagTranslat>[];

    for (final data in listData) {
      loggerNoStack.t('${data['namespace']}  ${data['count']}');
      final String namespace = data['namespace'] as String;
      Map mapC = data['data'] as Map;
      mapC.forEach((key, value) {
        final String keyName = key as String;
        final String name = (value['name'] ?? '') as String;
        final String intro = (value['intro'] ?? '') as String;
        final String links = (value['links'] ?? '') as String;

        tagTranslats.add(TagTranslat(
            namespace: namespace,
            key: keyName,
            name: name,
            intro: intro,
            links: links));
      });
    }

    await isarHelper.putAllTagTranslateIsolate(tagTranslats);
    ehSettingService.tagTranslatVer.value = _remoteVer ?? '';
  }

  /// 获取翻译结果
  Future<String?> _getTagTransStr(String key, {String? namespace}) async {
    TagTranslat? tr =
        await isarHelper.findTagTranslate(key, namespace: namespace);

    return tr?.nameNotMD ?? key;
  }

  Future<String?> getTranTagWithNameSpase(
    String tag, {
    String namespace = '',
  }) async {
    if (tag.contains(':')) {
      final RegExp rpfx = RegExp(r'(\w+):"?([^\$]+)\$?"?');
      final RegExpMatch? rult = rpfx.firstMatch(tag.toLowerCase());
      String nameSpase = rult?.group(1) ?? '';
      if (nameSpase.length == 1) {
        nameSpase = EHConst.prefixToNameSpaceMap[nameSpase] ?? nameSpase;
      }

      final String tag0 = rult?.group(2) ?? '';
      final String nameSpaseTran =
          EHConst.translateTagType[nameSpase] ?? nameSpase;
      final String transTag =
          await _getTagTransStr(tag0, namespace: nameSpase) ?? tag0;

      return '$nameSpaseTran:$transTag';
    } else {
      return await _getTagTransStr(tag.toLowerCase(), namespace: namespace);
    }
  }

  /// 自动拆分解析匹配查询tag翻译
  Future<String?> getTranTagWithNameSpaseAuto(String text) async {
    if (!text.trim().contains(' ')) {
      return await getTranTagWithNameSpase(text);
    }
    logger.t(text);
    final array = text.split(RegExp(r'\s+'));
    logger.t(array.map((e) => '[$e]').join(','));

    for (int i = 0; i < array.length; i++) {
      if (array[i].startsWith(RegExp(r'-?\w+:"?'))) {
        if (!RegExp(r'\$"?$').hasMatch(array[i])) {
          final tempArray = array.sublist(i);
          final offset = tempArray
              .indexWhere((element) => RegExp(r'\$"?$').hasMatch(element));
          for (int j = 0; j < offset; j++) {
            array[i] = '${array[i]} ${array[i + 1]}';
            array.removeAt(i + 1);
          }
        }
      }
    }

    logger.t(array.map((e) => '[$e]').join(''));

    final translateList = [];
    for (final text in array) {
      final String? translate = await getTranTagWithNameSpase(text);
      translateList.add(translate ?? text);
    }

    return translateList.join('   ');
  }

  Future<String?> getTagTranslateText(
    String text, {
    String? namespace,
    bool ignoreNamespace = false,
  }) async {
    if (text.contains(':')) {
      final RegExp regPfx = RegExp(r'(\w):(.+)');
      final RegExpMatch? rult = regPfx.firstMatch(text.toLowerCase());
      final String pfx = rult?.group(1) ?? '';
      final String? nameSpase = EHConst.prefixToNameSpaceMap[pfx];
      final String tag = rult?.group(2) ?? '';
      final String? transTag = await _getTagTransStr(tag, namespace: nameSpase);

      if (transTag == null) {
        return text;
      }

      if (ignoreNamespace) {
        return transTag;
      } else {
        return '$pfx:$transTag';
      }

      // return _transTag != null ? '$pfx:$_transTag' : text;
    } else {
      String? tempNamespace;
      if (_namespaces.contains(namespace)) {
        tempNamespace = namespace;
      }
      return await _getTagTransStr(text.toLowerCase(),
          namespace: tempNamespace);
    }
  }

  Future<TagTranslat?> getTagTranslate(String text, String namespace) async {
    final TagTranslat? translates =
        await isarHelper.findTagTranslate(text, namespace: namespace);

    logger.d(translates?.intro);
    // 查询code字段
    final qryMap = {};
    final RegExp regCode = RegExp(r'`(([\w:]+\s+?)*[\w:]+)`');
    final matches = regCode.allMatches(translates?.intro ?? '');
    for (final match in matches) {
      final ori = match.group(1);
      if (ori != null) {
        final translateCode = await getTagTranslateText(
          ori,
          ignoreNamespace: true,
        );
        if (translateCode != null && translateCode != ori) {
          logger.t('match $ori $translateCode');
          qryMap[ori] = translateCode;
        }
      }
    }

    final intro = translates?.intro?.replaceAllMapped(regCode,
        (match) => ' `${qryMap[match.group(1)]} (${match.group(1)})` ');
    logger.t(intro);

    return translates?.copyWith(intro: intro);
  }

  Future<List<TagTranslat>> getTagTranslatesLike(
      {String text = '', int limit = 100}) async {
    logger.d('getTagTranslatesLike $text');
    if (text.isEmpty) {
      return [];
    }

    final List<TagTranslat> translates =
        await isarHelper.findTagTranslateContains(text, limit);

    return translates;
  }

  Future<void> tapTagTranslate(TagTranslat tagTranslat) async {
    await isarHelper.tapTagTranslate(tagTranslat);
  }
}
