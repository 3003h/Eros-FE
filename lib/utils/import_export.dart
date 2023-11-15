import 'dart:convert';
import 'dart:io';

import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

Future<void> importQuickSearchFromFile() async {
  late final String _fileText;
  final QuickSearchController quickSearchController = Get.find();

  if (GetPlatform.isAndroid) {
    // SAF read file
    try {
      final uriList = await ss.openDocument();
      logger.d('uriList: $uriList');
      final uri = uriList?.first;
      logger.d('result: $uri');

      if (uri != null) {
        final byte = await ss.getDocumentContent(uri);
        if (byte != null) {
          // utf8
          _fileText = utf8.decode(byte);
          logger.d('$_fileText');
        }
      }
    } catch (e, s) {
      logger.e('$e\n$s');
    }
  } else {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final File _file = File(result.files.single.path!);
      logger.d(_file.path);
      _fileText = _file.readAsStringSync();
    }
  }

  if (_fileText.contains('#FEhViewer')) {
    logger.t(_fileText);
    final List<String> _importTexts = _fileText.split('\n');
    for (final element in _importTexts) {
      if (element.trim().isNotEmpty && !element.startsWith('#')) {
        quickSearchController.addText(element);
      }
    }
  }
}

Future<void> exportQuickSearchToFile() async {
  try {
    final _tempFilePath = await writeQuickSearchTempFile();
    if (_tempFilePath != null) {
      if (GetPlatform.isAndroid) {
        // SAF
        final saveToDirPath = await ss.openDocumentTree();
        if (saveToDirPath != null) {
          logger.d('$saveToDirPath');
          final bytes = File(_tempFilePath).readAsBytesSync();
          final file = await ss.createFileAsBytes(
            saveToDirPath,
            mimeType: '',
            displayName: path.basename(_tempFilePath),
            bytes: bytes,
          );
          logger.d('file: ${file?.uri}');
        }
      } else {
        if (Platform.isIOS) {
          Share.shareXFiles([
            XFile(
              _tempFilePath,
              mimeType: '*/*',
              name: path.basename(_tempFilePath),
            )
          ]);
          return;
        }

        logger.d('saveToDirPath');
        final saveToDirPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Save to',
        );
        logger.d('$saveToDirPath');
        if (saveToDirPath != null) {
          final _dstPath =
              path.join(saveToDirPath, path.basename(_tempFilePath));
          File(_tempFilePath).copySync(_dstPath);
        }
      }
    }
  } catch (e) {
    showToast('$e');
    rethrow;
  }
}

Future<void> importAppDataFromFile() async {
  late String loadedStr;
  if (GetPlatform.isAndroid) {
    // SAF
    try {
      final uriList = await ss.openDocument();
      final uri = uriList?.first;

      if (uri != null) {
        final byte = await ss.getDocumentContent(uri);
        if (byte != null) {
          // utf8
          loadedStr = utf8.decode(byte);
          logger.d('$loadedStr ');
        }
      }
    } catch (e, s) {
      logger.e('$e\n$s');
    }
  } else {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final PlatformFile platFile = result.files.single;
      final file = File(platFile.path!);
      loadedStr = file.readAsStringSync();
    }
  }

  late String jsonStr;
  if (loadedStr.trim().startsWith('{')) {
    logger.d('load json');
    jsonStr = loadedStr;
  } else {
    logger.d('load base64');
    final base64Str = loadedStr.trim();
    jsonStr = utf8.decode(base64.decode(base64Str));
  }

  final user = Global.profile.user.clone();

  final oriDownloadConfig = Global.profile.downloadConfig.clone();

  final Map<String, dynamic> jsonMap =
      jsonDecode(jsonStr) as Map<String, dynamic>;
  final Profile profile = Profile.fromJson(jsonMap);

  final _newDownloadConfig = profile.downloadConfig;

  Global.profile = profile.copyWith(
    user: user,
    downloadConfig: _newDownloadConfig.copyWith(
      downloadLocation: oriDownloadConfig.downloadLocation,
    ),
  );
  Global.saveProfile();
  Get.reloadAll(force: true);
  showToast('Import success');
}

Future<void> exportAppDataToFile({bool base64 = true}) async {
  final Profile profile = Global.profile.copyWith(user: kDefUser);
  final String jsonStr = jsonEncode(profile.toJson());
  final String base64Str = base64Encode(utf8.encode(jsonStr));
  final time = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final tempFilePath =
      path.join(Global.tempPath, 'fehviewer_profile_$time.json');
  final tempFile = File(tempFilePath);
  tempFile.writeAsStringSync(base64 ? base64Str : jsonStr);

  try {
    if (GetPlatform.isAndroid) {
      // SAF
      final saveToDirPath = await ss.openDocumentTree();
      if (saveToDirPath != null) {
        logger.d('$saveToDirPath');
        final bytes = tempFile.readAsBytesSync();
        final file = await ss.createFileAsBytes(
          saveToDirPath,
          mimeType: '*/*',
          displayName: path.basename(tempFilePath),
          bytes: bytes,
        );
        logger.d('file: ${file?.uri}');
      }
    } else {
      if (Platform.isIOS) {
        Share.shareXFiles([
          XFile(
            tempFilePath,
            mimeType: '*/*',
            name: path.basename(tempFilePath),
          )
        ]);
        return;
      }
      logger.d('saveToDirPath');
      final saveToDirPath = await FilePicker.platform.getDirectoryPath();
      logger.d('saveToDirPath $saveToDirPath');
      if (saveToDirPath != null) {
        final _dstPath = path.join(saveToDirPath, path.basename(tempFilePath));
        tempFile.copySync(_dstPath);
      }
    }
  } catch (e) {
    showToast('$e');
    rethrow;
  }
}

Future<String?> writeQuickSearchTempFile() async {
  final QuickSearchController quickSearchController = Get.find();
  final List<String> _searchTextList = quickSearchController.searchTextList;
  if (_searchTextList.isNotEmpty) {
    final String _searchText = '#FEhViewer\n${_searchTextList.join('\n')}';
    logger.t(_searchText);

    final File _tempFile = await getTempQuickSearchFile();
    _tempFile.writeAsStringSync(_searchText);
    return _tempFile.path;
  }
  return null;
}

Future<File> getTempQuickSearchFile() async {
  final DateTime _now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
  final String _fileName = formatter.format(_now);
  return File('${Global.appDocPath}/QSearch_$_fileName.txt');
}
