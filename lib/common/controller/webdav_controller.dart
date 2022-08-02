import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

const String kDirPath = '/fehviewer';
const String kHistoryDirPath = '/fehviewer/history';
const String kHistoryDtlDirPath = '/fehviewer/history/s';
const String kHistoryDelDirPath = '/fehviewer/history/del';

const String kReadDirPath = '/fehviewer/read';
const String kLocalReadDirPath = 'read';

const String kGroupDirPath = '/fehviewer/group';
const String kLocalGroupDirPath = 'group';
const String kGroupSeparator = '‖@‖';

const String kSearchDirPath = '/fehviewer/search';
const String kLocalSearchDirPath = 'search';
const String kQuickSearchFile = 'quickSearch';
const String kQuickSearchSeparator = '_';

const String idActionLogin = 'action_login';

const String kAESKey = 'fehviewer is very good!!';
const String kAESIV = '0000000000000000';

class WebdavController extends GetxController {
  late webdav.Client? client;

  WebdavProfile get webdavProfile =>
      Global.profile.webdav ?? const WebdavProfile(url: '');
  set webdavProfile(WebdavProfile val) =>
      Global.profile = Global.profile.copyWith(webdav: val);

  final _validAccount = false.obs;
  bool get validAccount => _validAccount.value;
  set validAccount(bool val) => _validAccount.value = val;

  final _isWaitLogin = false.obs;
  bool get isLongining => _isWaitLogin.value;
  set isLongining(bool val) => _isWaitLogin.value = val;

  // 是否同步历史记录
  final _syncHistory = false.obs;
  bool get syncHistory => _syncHistory.value;
  set syncHistory(bool val) => _syncHistory.value = val;

  // 是否同步画廊阅读进度
  final _syncReadProgress = false.obs;
  bool get syncReadProgress => _syncReadProgress.value;
  set syncReadProgress(bool val) => _syncReadProgress.value = val;

  final _syncGroupProfile = false.obs;
  bool get syncGroupProfile => _syncGroupProfile.value;
  set syncGroupProfile(bool val) => _syncGroupProfile.value = val;

  final _syncQuickSearch = false.obs;
  bool get syncQuickSearch => _syncQuickSearch.value;
  set syncQuickSearch(bool val) => _syncQuickSearch.value = val;

  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  // url
  final TextEditingController urlController = TextEditingController();

  // user
  final TextEditingController usernameController = TextEditingController();

  // passwd
  final TextEditingController passwdController = TextEditingController();

  final FocusNode nodeUser = FocusNode();
  final FocusNode nodePwd = FocusNode();

  bool loadingLogin = false;
  bool obscurePasswd = true;

  void switchObscure() {
    obscurePasswd = !obscurePasswd;
    update();
  }

  Future<bool?> pressLoginWebDAV() async {
    if (loadingLogin) {
      return null;
    }

    loadingLogin = true;
    final rult = await addWebDAVProfile(
      urlController.text,
      user: usernameController.text,
      pwd: passwdController.text,
    );

    loadingLogin = false;
    return rult;
  }

  @override
  void onInit() {
    super.onInit();
    if (webdavProfile.url.isNotEmpty) {
      initClient();
    }

    syncHistory = webdavProfile.syncHistory ?? false;
    ever(_syncHistory, (bool val) {
      webdavProfile = webdavProfile.copyWith(syncHistory: val);
      Global.saveProfile();
    });

    syncReadProgress = webdavProfile.syncReadProgress ?? false;
    ever(_syncReadProgress, (bool val) {
      webdavProfile = webdavProfile.copyWith(syncReadProgress: val);
      Global.saveProfile();
    });

    syncGroupProfile = webdavProfile.syncGroupProfile ?? false;
    ever(_syncGroupProfile, (bool val) {
      webdavProfile = webdavProfile.copyWith(syncGroupProfile: val);
      Global.saveProfile();
    });

    syncQuickSearch = webdavProfile.syncQuickSearch ?? false;
    ever(_syncQuickSearch, (bool val) {
      webdavProfile = webdavProfile.copyWith(syncQuickSearch: val);
      Global.saveProfile();
    });

    _key = encrypt.Key.fromUtf8(kAESKey);
    _iv = encrypt.IV.fromUtf8(kAESIV);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  void closeClient() {
    client = null;
  }

  void initClient() {
    logger.d('initClient');
    client = webdav.newClient(
      webdavProfile.url,
      user: webdavProfile.user ?? '',
      password: webdavProfile.password ?? '',
      // debug: true,
    );

    // Set the public request headers
    client?.setHeaders({'accept-charset': 'utf-8'});

    // Set the connection server timeout time in milliseconds.
    client?.setConnectTimeout(8000);

    // Set send data timeout time in milliseconds.
    client?.setSendTimeout(8000);

    // Set transfer data time in milliseconds.
    client?.setReceiveTimeout(8000);

    checkDir(dir: kHistoryDtlDirPath)
        .then((value) => checkDir(dir: kHistoryDelDirPath))
        .then((value) => checkDir(dir: kReadDirPath))
        .then((value) => checkDir(dir: kGroupDirPath))
        .then((value) => checkDir(dir: kSearchDirPath));

    validAccount = webdavProfile.user?.isNotEmpty ?? false;
  }

  Future<void> checkDir({String dir = kDirPath}) async {
    if (client == null) {
      return;
    }
    try {
      final list = await client!.readDir(dir);
      logger.v('$dir\n${list.map((e) => '${e.name} ${e.mTime}').join('\n')}');
    } on DioError catch (err) {
      if (err.response?.statusCode == 404) {
        logger.d('dir $dir 404, mkdir...');
        await client!.mkdirAll(dir);
      }
    }
  }

  String _getIndexFileName() {
    final DateTime _now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    final String _fileName = formatter.format(_now);
    return 'fe_his_index_$_fileName';
  }

  Future<List<String>> getRemotFileList() async {
    if (client == null) {
      return [];
    }
    final list = await client!.readDir(kHistoryDtlDirPath);
    final names = list.map((e) => e.name).toList();
    final _list = <String>[];
    for (final name in names) {
      if (name != null && name.endsWith('.json')) {
        _list.add(name.substring(0, name.indexOf('.')));
      }
    }
    return _list;
  }

  Future<List<String>> getRemotDeleteList() async {
    if (client == null) {
      return [];
    }
    final list = await client!.readDir(kHistoryDelDirPath);
    final names = list.map((e) => e.name).toList();
    final _list = <String>[];
    for (final name in names) {
      if (name != null) {
        _list.add(name);
      }
    }
    return _list;
  }

  Future updateRemoveFlg(String gid) async {
    if (client == null) {
      return;
    }
    await client!.write('$kHistoryDelDirPath/$gid', Uint8List.fromList([]));
  }

  Future<List<HistoryIndexGid>> getRemoteHistoryList() async {
    if (client == null) {
      return [];
    }
    final list = await client!.readDir(kHistoryDtlDirPath);
    final hisObjs = list.map((e) {
      final name = e.name?.substring(0, e.name?.lastIndexOf('.'));
      final gid = name?.split('_')[0];
      final time = int.parse(name?.split('_')[1] ?? '0');
      return HistoryIndexGid(g: gid, t: time);
    }).toList();
    final _list = <HistoryIndexGid>[];
    for (final his in hisObjs) {
      if (his.g != null && his.t! > 0) {
        _list.add(his);
      }
    }
    return _list;
  }

  int _mTime2MillisecondsSinceEpoch(String mTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final _mTime = formatter.parse(mTime);
    return _mTime.millisecondsSinceEpoch;
  }

  // 上传历史记录
  Future<void> uploadHistory(GalleryProvider his) async {
    if (client == null) {
      return;
    }
    logger.v('uploadHistory');
    final _path = path.join(Global.tempPath, his.gid);
    final File _file = File(_path);
    final _his = his.copyWith(
      galleryComment: [],
      galleryImages: [],
      tagGroup: [],
    );

    try {
      final _text = jsonEncode(_his);
      // final base64Text = base64Encode(utf8.encode(_text));
      final encrypted = _encrypter.encrypt(_text, iv: _iv);
      logger.v('encrypted.base64 ${encrypted.base64}');
      _file.writeAsStringSync(encrypted.base64);

      await client!.writeFromFile(
          _path, '$kHistoryDtlDirPath/${his.gid}_${his.lastViewTime}.json');
    } on DioError catch (err) {
      logger.d('${err.response?.statusCode}');
      if (err.response?.statusCode == 404) {
        logger.d('file 404');
        rethrow;
      } else {
        rethrow;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      // rethrow;
    }
  }

  // 下载历史记录
  Future<GalleryProvider?> downloadHistory(String fileName) async {
    if (client == null) {
      return null;
    }
    logger.v('downloadHistory');
    final _path = path.join(Global.tempPath, fileName);
    try {
      await client!.read2File('$kHistoryDtlDirPath/$fileName.json', _path);
      final File _file = File(_path);
      if (!_file.existsSync()) {
        return null;
      }
      final String _fileText = _file.readAsStringSync();

      late String jsonText;
      if (_fileText.startsWith('{')) {
        jsonText = _fileText;
      } else {
        // jsonText = utf8.decode(base64Decode(_fileText));
        jsonText = _encrypter.decrypt64(_fileText, iv: _iv);
      }
      final _image = GalleryProvider.fromJson(
          jsonDecode(jsonText) as Map<String, dynamic>);

      return _image;
    } catch (err) {
      logger.e('$err');
      return null;
    }
  }

  void chkTempDir(String tempPath) {
    final _dirPath = path.join(Global.tempPath, tempPath);
    final Directory _directory = Directory(_dirPath);
    if (!_directory.existsSync()) {
      _directory.createSync(recursive: true);
    }
  }

  // 上传进度
  Future<void> uploadRead(GalleryCache read) async {
    if (client == null) {
      return;
    }
    logger.v('upload Read [${read.toJson()}] ');
    chkTempDir(kLocalReadDirPath);

    final _path = path.join(Global.tempPath, 'read', read.gid);
    final File _file = File(_path);
    final _read = read.copyWith(
      columnModeVal: '',
    );
    final _text = jsonEncode(_read);
    // final base64Text = base64Encode(utf8.encode(_text));
    final encrypted = _encrypter.encrypt(_text, iv: _iv);
    _file.writeAsStringSync(encrypted.base64);

    try {
      await client!.writeFromFile(_path, '$kReadDirPath/${read.gid}.json');
    } on DioError catch (err) {
      logger.d('${err.response?.statusCode}');
      if (err.response?.statusCode == 404) {
        logger.d('file 404');
        rethrow;
      } else {
        rethrow;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }

  // 下载进度
  Future<GalleryCache?> downloadRead(String gid) async {
    if (client == null) {
      return null;
    }
    logger.d('downloadRead');
    chkTempDir(kLocalReadDirPath);
    final _path = path.join(Global.tempPath, 'read', gid);
    try {
      await client!.read2File('$kReadDirPath/$gid.json', _path);
      final File _file = File(_path);
      if (!_file.existsSync()) {
        return null;
      }
      final String _fileText = _file.readAsStringSync();
      late String jsonText;
      if (_fileText.startsWith('{')) {
        jsonText = _fileText;
      } else {
        // jsonText = utf8.decode(base64Decode(_fileText));
        jsonText = _encrypter.decrypt64(_fileText, iv: _iv);
      }
      final _read =
          GalleryCache.fromJson(jsonDecode(jsonText) as Map<String, dynamic>);

      return _read;
    } catch (err) {
      logger.e('$err');
      return null;
    }
  }

  Future<List<String>> getRemotReadList() async {
    if (client == null) {
      return [];
    }
    final list = await client!.readDir(kReadDirPath);
    final names = list
        .map((e) => e.name?.substring(0, e.name?.lastIndexOf('.')))
        .toList();
    final _list = <String>[];
    for (final name in names) {
      if (name != null) {
        _list.add(name);
      }
    }
    return _list;
  }

  // 上传分组
  Future<void> uploadGroupProfile(CustomProfile profile,
      {bool isEncrypt = false}) async {
    if (client == null) {
      return;
    }
    logger.d('upload group');
    chkTempDir(kLocalGroupDirPath);

    final _path = path.join(Global.tempPath, kLocalGroupDirPath, profile.name);
    final File _file = File(_path);

    final _text = jsonEncode(profile);
    // logger.d('upload group\n$_text');
    if (isEncrypt) {
      final encrypted = _encrypter.encrypt(_text, iv: _iv);
      _file.writeAsStringSync(encrypted.base64);
    } else {
      _file.writeAsStringSync(_text);
    }

    try {
      await client!
          .writeFromFile(_path, '$kGroupDirPath/${profile.syncFileName}.json');
    } on DioError catch (err) {
      logger.d('${err.response?.statusCode}');
      if (err.response?.statusCode == 404) {
        logger.d('file 404');
        rethrow;
      } else {
        rethrow;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }

  // 下载分组
  Future<CustomProfile?> downloadGroupProfile(CustomProfile profile) async {
    if (client == null) {
      return null;
    }
    logger.d('download group ${profile.syncFileName}');
    chkTempDir(kLocalGroupDirPath);
    final _path =
        path.join(Global.tempPath, kLocalGroupDirPath, profile.syncFileName);
    try {
      await client!
          .read2File('$kGroupDirPath/${profile.syncFileName}.json', _path);
      final File _file = File(_path);
      if (!_file.existsSync()) {
        return null;
      }
      final String _fileText = _file.readAsStringSync();

      late String jsonText;
      if (_fileText.startsWith('{')) {
        jsonText = _fileText;
      } else {
        jsonText = _encrypter.decrypt64(_fileText, iv: _iv);
      }
      final _group =
          CustomProfile.fromJson(jsonDecode(jsonText) as Map<String, dynamic>);

      return _group.copyWith(name: profile.name, uuid: profile.uuid);
    } catch (err) {
      logger.e('$err');
      return null;
    }
  }

  Future<List<CustomProfile>> getRemotGroupList() async {
    if (client == null) {
      return [];
    }
    final list = await client!.readDir(kGroupDirPath);
    final profileObjs = list.map((e) {
      final name = e.name?.substring(0, e.name?.lastIndexOf('.'));
      final arr = name?.split(kGroupSeparator);
      final profileName = arr?.take(arr.length - 2).join(kGroupSeparator) ?? '';
      final uuid = arr?[arr.length - 2] ?? generateUuidv4();
      final time = int.parse(arr?[arr.length - 1] ?? '0');
      if (profileName.isNotEmpty) {
        return CustomProfile(name: profileName, uuid: uuid, lastEditTime: time);
      }
    }).toList();
    final _list = <CustomProfile>[];
    for (final profile in profileObjs) {
      if (profile != null) {
        _list.add(profile);
      }
    }
    return _list;
  }

  Future<void> deleteRemotGroup(CustomProfile? oriRemote) async {
    if (client == null || oriRemote == null) {
      return;
    }

    try {
      await client!.remove('$kGroupDirPath/${oriRemote.syncFileName}.json');
    } catch (err) {
      logger.e('$err');
      return;
    }
  }

  Future<void> uploadQuickSearch(List<String> texts, int time) async {
    if (client == null) {
      return;
    }
    chkTempDir(kLocalSearchDirPath);

    final _path =
        path.join(Global.tempPath, kLocalGroupDirPath, kQuickSearchFile);
    final File _file = File(_path);

    final _text = texts.join('\n');
    _file.writeAsStringSync(_text);
    // final encrypted = _encrypter.encrypt(_text, iv: _iv);
    // _file.writeAsStringSync(encrypted.base64);

    try {
      await client!.writeFromFile(
          _path, '$kSearchDirPath/${kQuickSearchFile}_$time.txt');
    } on DioError catch (err) {
      logger.d('${err.response?.statusCode}');
      if (err.response?.statusCode == 404) {
        logger.d('file 404');
        rethrow;
      } else {
        rethrow;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }

  Future<Tuple2<List<String>, int>?> downloadQuickSearch(int maxTime) async {
    if (client == null) {
      return null;
    }

    logger.d('download $kQuickSearchFile');
    chkTempDir(kLocalSearchDirPath);

    final _path =
        path.join(Global.tempPath, kLocalSearchDirPath, kQuickSearchFile);
    try {
      await client!
          .read2File('$kSearchDirPath/${kQuickSearchFile}_$maxTime.txt', _path);
      final File _file = File(_path);
      if (!_file.existsSync()) {
        return null;
      }
      final String _fileText = _file.readAsStringSync();

      return Tuple2(
          _fileText
              .split('\n')
              .where((element) => element.trim().isNotEmpty)
              .toList(),
          maxTime);
    } catch (err) {
      logger.e('$err');
      return null;
    }
  }

  Future<List<int>> getQuickList() async {
    if (client == null) {
      return [0];
    }

    final list = (await client!.readDir(kSearchDirPath)).where(
        (element) => element.name?.startsWith(kQuickSearchFile) ?? false);

    final _filte = list.map((e) {
      final name = e.name?.substring(0, e.name?.lastIndexOf('.'));
      final arr = name?.split(kQuickSearchSeparator);
      return int.parse(arr?[arr.length - 1] ?? '0');
    }).toList();

    return _filte;
  }

  Future<void> deleteQuickSearch(int time) async {
    if (client == null) {
      return;
    }

    try {
      await client!.remove(
          '$kSearchDirPath/$kQuickSearchFile$kQuickSearchSeparator$time.txt');
    } catch (err) {
      logger.e('$err');
      return;
    }
  }

  Future<void> _pingWebDAV(String url, {String? user, String? pwd}) async {
    final client = webdav.newClient(
      url,
      user: user ?? '',
      password: pwd ?? '',
    );

    await client.ping();
  }

  Future<bool> addWebDAVProfile(String url, {String? user, String? pwd}) async {
    isLongining = true;
    bool rult = false;
    try {
      _pingWebDAV(url, user: user, pwd: pwd);
      rult = true;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      showToast('$e\n$stack');
    }
    if (rult) {
      // 保存账号 rebuild
      WebdavProfile webdavUser =
          WebdavProfile(url: url, user: user, password: pwd);
      Global.profile = Global.profile.copyWith(webdav: webdavUser);
      Global.saveProfile();
      initClient();
    }
    isLongining = false;
    return rult;
  }

  Future<void> deleteHistory(HistoryIndexGid? oriRemote) async {
    if (client == null || oriRemote == null) {
      return;
    }

    try {
      await client!
          .remove('$kHistoryDtlDirPath/${oriRemote.g}_${oriRemote.t}.json');
    } catch (err) {
      logger.e('$err');
      return;
    }
  }

  String encryptAES(String plainText) {
    return '';
  }

  Future<void> readFromClipboard() async {
    final String _clipText =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    final texts =
        _clipText.split('\n').where((e) => e.trim().isNotEmpty).toList();
    if (texts.length < 3) {
      return;
    }

    urlController.text = texts[0].trim();
    usernameController.text = texts[1].trim();
    passwdController.text = texts[2].trim();
  }
}
