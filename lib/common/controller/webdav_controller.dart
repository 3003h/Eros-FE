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

const String idActionLogin = 'action_login';

class WebdavController extends GetxController {
  late webdav.Client? client;

  WebdavProfile get webdavProfile => Get.find();

  bool get validAccount => webdavProfile.url.isNotEmpty;

  bool isLongining = false;

  bool get syncHistory => webdavProfile.syncHistory ?? false;
  set syncHistory(bool val) {
    final _dav = webdavProfile.copyWith(syncHistory: val);
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
        .then((value) => checkDir(dir: kHistoryDelDirPath));
  }

  Future<void> checkDir({String dir = kDirPath}) async {
    if (client == null) {
      return;
    }
    try {
      final list = await client!.readDir(dir);
      logger.d('$dir\n${list.map((e) => '${e.name} ${e.mTime}').join('\n')}');
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
      if (name != null) {
        _list.add(name);
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
    // final _path = path.join(Global.tempPath, 'del', gid);
    // final File _file = File(_path);
    // _file.create();
    // await client!.writeFromFile(_path, '$kHistoryDelDirPath/$gid');
    await client!.write('$kHistoryDelDirPath/$gid', Uint8List.fromList([]));
  }

  Future<HistoryIndex?> downloadHistoryList() async {
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
    logger.d('_fileText\n$_fileText');

    try {
      final _index =
          HistoryIndex.fromJson(jsonDecode(_fileText) as Map<String, dynamic>);

      return _index;
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadHistoryList(List<HistoryIndexGid?> gids, int time) async {
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
    logger.d('upload :\n$_text');
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
    // logger.d('${_his.galleryImages?.length}');

    final _text = jsonEncode(_his);
    _file.writeAsStringSync(_text);

    try {
      await client!.writeFromFile(_path, '$kHistoryDtlDirPath/${his.gid}.json');
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

  Future<GalleryItem?> downloadHistory(String gid) async {
    if (client == null) {
      return null;
    }
    final _path = path.join(Global.tempPath, gid);
    try {
      await client!.read2File('$kHistoryDtlDirPath/$gid.json', _path);
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
}
