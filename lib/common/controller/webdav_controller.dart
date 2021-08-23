import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as path;

import '../global.dart';

const String kDirPath = '/fehviewer';
const String kHistoryDirPath = '/fehviewer/history';
const String kHistoryDtlDirPath = '/fehviewer/history/s';
const String kHistoryDelDirPath = '/fehviewer/history/del';
const String kReadDirPath = '/fehviewer/read';

const String idActionLogin = 'action_login';

class WebdavController extends GetxController {
  late webdav.Client? client;

  WebdavProfile get webdavProfile => Get.find();

  bool get validAccount => webdavProfile.url.isNotEmpty;

  bool isLongining = false;

  bool get syncHistory => webdavProfile.syncHistory ?? false;
  bool get syncReadProgress => webdavProfile.syncReadProgress ?? false;

  set syncHistory(bool val) {
    final _dav = webdavProfile.copyWith(syncHistory: val);
    Get.replace(_dav);
    update();
    Global.profile = Global.profile.copyWith(webdav: _dav);
    Global.saveProfile();
  }

  set syncReadProgress(bool val) {
    final _dav = webdavProfile.copyWith(syncReadProgress: val);
    Get.replace(_dav);
    update();
    Global.profile = Global.profile.copyWith(webdav: _dav);
    Global.saveProfile();
  }

  @override
  void onInit() {
    super.onInit();
    if (webdavProfile.url.isNotEmpty) {
      initClient();
    }
  }

  void close() {
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
        .then((value) => checkDir(dir: kReadDirPath));
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
        logger.d('dir 404, mkdir...');
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

  Future<HistoryIndex?> downloadHistoryList_Old() async {
    if (client == null) {
      return null;
    }
    final _path = path.join(Global.tempPath, _getIndexFileName());
    try {
      await client!.read2File('$kHistoryDirPath/index.json', _path);
    } on DioError catch (err) {
      if (err.response?.statusCode == 404) {
        logger.d('file 404');
        return null;
      } else {
        rethrow;
      }
    }

    final File _file = File(_path);
    if (!_file.existsSync()) {
      return null;
    }
    final String _fileText = _file.readAsStringSync();
    logger.v('_fileText\n$_fileText');

    try {
      final _index =
          HistoryIndex.fromJson(jsonDecode(_fileText) as Map<String, dynamic>);

      return _index;
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadHistoryIndex(List<HistoryIndexGid?> gids, int time) async {
    if (client == null) {
      return;
    }
    final _path = path.join(Global.tempPath, _getIndexFileName());
    final File _file = File(_path);
    final _gids = <HistoryIndexGid>[];
    for (final gid in gids) {
      if (gid != null) {
        _gids.add(gid);
      }
    }
    final _index = HistoryIndex(time: time, gids: _gids);
    final _text = jsonEncode(_index);
    logger.v('upload :\n$_text');
    _file.writeAsStringSync(_text);

    await client!.writeFromFile(_path, '$kHistoryDirPath/index.json');
  }

  Future<void> uploadHistory(GalleryItem his) async {
    if (client == null) {
      return;
    }
    final _path = path.join(Global.tempPath, his.gid);
    final File _file = File(_path);
    final _his = his.copyWith(
      galleryComment: [],
      galleryImages: [],
      tagGroup: [],
    );
    final _text = jsonEncode(_his);
    _file.writeAsStringSync(_text);

    try {
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
    }
  }

  Future<GalleryItem?> downloadHistory(String fileName) async {
    if (client == null) {
      return null;
    }
    final _path = path.join(Global.tempPath, fileName);
    try {
      await client!.read2File('$kHistoryDtlDirPath/$fileName.json', _path);
      final File _file = File(_path);
      if (!_file.existsSync()) {
        return null;
      }
      final String _fileText = _file.readAsStringSync();
      final _image =
          GalleryItem.fromJson(jsonDecode(_fileText) as Map<String, dynamic>);

      return _image;
    } catch (err) {
      return null;
    }
  }

  void chkReadTempDir() {
    final _dirPath = path.join(Global.tempPath, 'read');
    final Directory _directory = Directory(_dirPath);
    if (!_directory.existsSync()) {
      _directory.createSync(recursive: true);
    }
  }

  Future<void> uploadRead(GalleryCache read) async {
    if (client == null) {
      return;
    }
    chkReadTempDir();

    final _path = path.join(Global.tempPath, 'read', read.gid);
    final File _file = File(_path);
    final _read = read.copyWith(
      columnModeVal: '',
    );
    final _text = jsonEncode(_read);
    _file.writeAsStringSync(_text);

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
    }
  }

  Future<GalleryCache?> downloadRead(String gid) async {
    if (client == null) {
      return null;
    }
    chkReadTempDir();
    final _path = path.join(Global.tempPath, 'read', gid);
    try {
      await client!.read2File('$kReadDirPath/$gid.json', _path);
      final File _file = File(_path);
      if (!_file.existsSync()) {
        return null;
      }
      final String _fileText = _file.readAsStringSync();
      final _read =
          GalleryCache.fromJson(jsonDecode(_fileText) as Map<String, dynamic>);

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

  Future<bool> _pingWebDAV(String url, {String? user, String? pwd}) async {
    final client = webdav.newClient(
      url,
      user: user ?? '',
      password: pwd ?? '',
    );
    try {
      await client.ping();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addWebDAVProfile(String url, {String? user, String? pwd}) async {
    isLongining = true;
    update([idActionLogin]);
    final rult = await _pingWebDAV(url, user: user, pwd: pwd);
    if (rult) {
      // 保存账号 rebuild
      WebdavProfile webdavUser =
          WebdavProfile(url: url, user: user, password: pwd);
      Global.profile = Global.profile.copyWith(webdav: webdavUser);
      Global.saveProfile();
      Get.replace(webdavUser);
      initClient();
    }
    isLongining = false;
    // update([idActionLogin]);
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
}
