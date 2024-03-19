import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/network/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../index.dart';

const _uuid = Uuid();
String generateUuidv4() {
  return _uuid.v4();
}

Future<Iterable<String>> readLastNLines(String filePath, int n) async {
  final file = File(filePath);
  final length = await file.length();
  const blockSize = 1024; // Adjust the block size based on your needs

  RandomAccessFile raf = await file.open(mode: FileMode.read);
  int position = length - blockSize;
  int newlineCount = 0;
  List<int> lines = [];

  while (position >= 0 && newlineCount < n) {
    final blockSizeToRead =
        position + blockSize > length ? length - position : blockSize;
    await raf.setPosition(position);
    List<int> block = await raf.read(blockSizeToRead);

    for (int i = block.length - 1; i >= 0; i--) {
      int byte = block[i];
      if (byte == 10) {
        // Check for newline character (ASCII 10)
        newlineCount++;
        lines.add(byte);
      } else if (byte != 13) {
        // Exclude carriage return (ASCII 13)
        lines.add(byte);
      }
    }

    position -= blockSize;
  }

  // Reverse the list to get the lines in correct order
  lines = lines.reversed.toList();

  // Convert the list of bytes to a String
  final lastNLines = utf8.decode(lines);

  // print(lastNLines);

  await raf.close();

  return lastNLines.split('\n');
}

/// 为 Dart 字符串优化后 FNV-1a 64bit 哈希算法
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

int downloadStatusToInt(DownloadTaskStatus status) {
  switch (status) {
    case DownloadTaskStatus.undefined:
      return 0;
    case DownloadTaskStatus.enqueued:
      return 1;
    case DownloadTaskStatus.running:
      return 2;
    case DownloadTaskStatus.complete:
      return 3;
    case DownloadTaskStatus.failed:
      return 4;
    case DownloadTaskStatus.canceled:
      return 5;
    case DownloadTaskStatus.paused:
      return 6;
    default:
      return 0;
  }
}

DownloadTaskStatus intToDownloadStatus(int status) {
  switch (status) {
    case 0:
      return DownloadTaskStatus.undefined;
    case 1:
      return DownloadTaskStatus.enqueued;
    case 2:
      return DownloadTaskStatus.running;
    case 3:
      return DownloadTaskStatus.complete;
    case 4:
      return DownloadTaskStatus.failed;
    case 5:
      return DownloadTaskStatus.canceled;
    case 6:
      return DownloadTaskStatus.paused;
    default:
      return DownloadTaskStatus.undefined;
  }
}

// 请求完全读写权限
@Deprecated('use SAF')
Future<void> requestManageExternalStoragePermission() async {
  if (!GetPlatform.isAndroid) {
    return;
  }

  final androidInfo = await deviceInfo.androidInfo;
  final sdkInt = androidInfo.version.sdkInt;
  if (sdkInt < 30) {
    logger.d('sdkInt $sdkInt < 30');
    return;
  }

  final PermissionStatus statusMStorage =
      await Permission.manageExternalStorage.status;
  logger.d('manageExternalStorage $statusMStorage');

  // 始终拒绝
  if (statusMStorage.isPermanentlyDenied) {
    if (await Permission.manageExternalStorage.request().isGranted) {
      return;
    } else {
      showToast('Permission is permanently denied, open App Settings');
      openAppSettings();
      logger.d('jump to setting');
    }
  } else {
    if (await Permission.manageExternalStorage.request().isGranted) {
      return;
    } else {
      throw 'Unable to download, please authorize Permission manageExternalStorage first~';
    }
  }
}

// check photos Permission
Future<bool> requestPhotosPermission({
  BuildContext? context,
  bool addOnly = true,
}) async {
  // if ios
  if (GetPlatform.isIOS) {
    final PermissionStatus statusPhotos = await Permission.photos.status;
    final PermissionStatus statusPhotosAdd =
        await Permission.photosAddOnly.status;

    logger.d('statusPhotos $statusPhotos, statusPhotosAdd $statusPhotosAdd');

    if (addOnly) {
      // 永久拒绝 直接跳转到设置
      if (statusPhotosAdd.isPermanentlyDenied && context != null) {
        _jumpToAppSettings(context);
        return false;
      }

      // 拒绝 申请权限
      if (statusPhotosAdd.isDenied) {
        logger.d('photosAddOnly isDenied');
        if (await Permission.photosAddOnly.request().isLimited ||
            await Permission.photosAddOnly.request().isGranted) {
          return await Permission.photosAddOnly.status.isLimited ||
              await Permission.photosAddOnly.status.isGranted;
        } else {
          throw EhError(error: 'Unable to download, please authorize first~');
        }
      }
    } else {
      // 永久拒绝 直接跳转到设置
      if (statusPhotos.isPermanentlyDenied && context != null) {
        _jumpToAppSettings(context);
        return false;
      }

      // 拒绝 申请权限
      if (statusPhotos.isDenied) {
        if (await Permission.photos.request().isGranted ||
            await Permission.photos.request().isLimited) {
          return await Permission.photos.status.isGranted ||
              await Permission.photos.status.isLimited;
        } else {
          throw EhError(error: 'Unable to download, please authorize first~');
        }
      }
    }
  }

  // android
  if (GetPlatform.isAndroid) {
    final PermissionStatus statusStorage = await Permission.storage.status;
    logger.d('statusStorage $statusStorage');
    final PermissionStatus statusPhotos = await Permission.photos.status;
    logger.d('statusPhotos $statusPhotos');

    final _androidInfo = await deviceInfo.androidInfo;

    // SDK 33 以上, 申请照片权限
    if (_androidInfo.version.sdkInt >= 33) {
      // 非永久拒绝 申请权限
      if (!statusPhotos.isPermanentlyDenied) {
        if (await Permission.photos.request().isGranted) {
          return await Permission.photos.status.isGranted;
        } else {
          throw EhError(error: 'Photos Permission is denied');
        }
      }
    } else {
      // 存储权限申请
      if (!statusStorage.isPermanentlyDenied) {
        if (await Permission.storage.request().isGranted) {
          return await Permission.storage.status.isGranted;
        } else {
          throw EhError(error: 'Storage Permission is denied');
        }
      }
    }

    if (context != null) {
      await _jumpToAppSettings(context);
      return false;
    } else {
      throw EhError(
          error: 'Permission is permanently denied, open App Settings');
    }
  }

  return true;
}

/// 跳转权限设置
Future<bool?> _jumpToAppSettings(BuildContext context) async {
  return await jumpToAppSettings(
      context,
      'You have disabled the necessary permissions for the application:'
      '\nRead and write phone storage, is it allowed in the settings?');
}

/// 跳转权限设置
Future<bool?> jumpToAppSettings(BuildContext context, String content) async {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Container(
          child: Text(content),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(L10n.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          CupertinoDialogAction(
            child: Text(L10n.of(context).ok),
            onPressed: () {
              // 跳转
              openAppSettings();
            },
          ),
        ],
      );
    },
  );
}

/// 计算文本 Size
Size getTextSize(
  String text,
  TextStyle style, {
  int maxLines = 1,
  TextDirection textDirection = TextDirection.ltr,
  double minWidth = 0.0,
  double maxWidth = double.infinity,
}) {
  TextPainter painter = TextPainter(
    ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
    locale: WidgetsBinding.instance.window.locale,
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    maxLines: maxLines,
    ellipsis: '...',
  );
  painter.layout(
    maxWidth: maxWidth,
    minWidth: minWidth,
  );
  return painter.size;
}

T randomList<T>(Iterable<T> srcList) {
  final index = Random().nextInt(srcList.length);
  return srcList.toList()[index];
}

double? initScaleWithSize({
  required Size imageSize,
  required Size size,
  double? initialScale,
}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;
  if (n1 > n2) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.width / destinationSize.width;
  } else if (n1 / n2 < 1 / 4) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.height / destinationSize.height;
  }

  return initialScale;
}

double? initScale({
  required Size imageSize,
  required Size size,
  required double initialScale,
}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;

  final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
  logger.t(
      'source: ${fittedSizes.source}  destination:${fittedSizes.destination}');

  // logger.d('n2/n1 ${n2 / n1}');
  if (n2 / n1 > 1 / initialScale) {
    logger.t('H');
    return initialScale;
  }

  // logger.d('n1/n2 ${n1 / n2}');
  if (n1 / n2 > 1 / initialScale) {
    logger.t('fitHeight');
    return 1.0;
  }

  logger.t('other ${size.height / fittedSizes.destination.height}');

  return fittedSizes.destination.height / size.height;
}

double scaleScreen({
  required Size imageSize,
  required Size size,
}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;

  final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
  //final Size sourceSize = fittedSizes.source;
  final Size destinationSize = fittedSizes.destination;
  if (n1 > n2) {
    // 屏幕更高
    return size.width / destinationSize.width;
  } else {
    // 屏幕更宽
    return size.height / destinationSize.height;
  }
}

double scale100({
  required Size imageSize,
  required Size size,
}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;

  if (n2 > n1) {
    // 屏幕更高
    return imageSize.width / size.width;
  } else {
    // 屏幕更宽
    return imageSize.height / size.height;
  }
}

///格式化文件大小
String renderSize(int inValue) {
  double value = inValue.toDouble();
  final List<String> unitArr = <String>['B', 'K', 'M', 'G'];
  int index = 0;
  while (value > 1024) {
    index++;
    value = value / 1024;
  }
  final String size = value.toStringAsFixed(2);
  return '$size ${unitArr[index]}';
}

Future<void> onOpenUrl({String? url}) async {
  vibrateUtil.light();

  final String? _openUrl = Uri.encodeFull(url ?? '');

  if (!await _launchEhUrl(url)) {
    throw 'Could not launch $_openUrl';
  }
}

Future<bool> _launchEhUrl(String? url) async {
  final String? _openUrl = Uri.encodeFull(url ?? '');
  final RegExp regExp = RegExp(
      r'https?://e[-x]hentai.org/(g/[0-9]+/[0-9a-z]+|s/[0-9a-z]+/\d+-\d+)/?');
  if (regExp.hasMatch(_openUrl!)) {
    final String? _realUrl = regExp.firstMatch(_openUrl)?.group(0);
    logger.t('in $_realUrl');
    NavigatorUtil.goGalleryPage(
      url: _realUrl,
    );
    return true;
  } else {
    return await launchUrlString(
      _openUrl,
      mode: LaunchMode.externalApplication,
    );
  }
}

class EHUtils {
  static Uint8List stringToUint8List(String source) {
    /*logger.d('${source.length}: "$source" (${source.runes.length})');

    // String (Dart uses UTF-16) to bytes
    final List<int> list = <int>[];
    // ignore: avoid_function_literals_in_foreach_calls
    source.runes.forEach((int rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        final int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        final int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    return Uint8List.fromList(list);*/
    final List<int> list = source.codeUnits;
    final Uint8List bytes = Uint8List.fromList(list);
    // final String string = String.fromCharCodes(bytes);
    return bytes;
  }

  static String stringToHex(String source) {
    final List<int> list = source.codeUnits;
    final Uint8List bytes = Uint8List.fromList(list);
    return formatBytesAsHexString(bytes);
  }

  /// Converts binary data to a hexdecimal representation.
  static String formatBytesAsHexString(Uint8List bytes) {
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < bytes.lengthInBytes; i++) {
      final int part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return result.toString();
  }

  /// Converts a hexdecimal representation to binary data.
  static Uint8List createUint8ListFromHexString(String hex) {
    final Uint8List result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      final String num = hex.substring(i, i + 2);
      final int byte = int.parse(num, radix: 16);
      result[i ~/ 2] = byte;
    }
    return result;
  }

  static String getLanguage(String value) {
    for (final String key in EHConst.iso936.keys) {
      if (key.toUpperCase().trim() == value.toUpperCase().trim()) {
        return EHConst.iso936[key] ?? EHConst.iso936.values.first;
      }
    }
    return '';
  }

  // String (Dart uses UTF-16) to bytes
  static Uint8List stringToBytes(String source) {
    final list = <int>[];
    source.runes.forEach((rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        final int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        final int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }

  // Bytes to UTF-16 string
  static String byteToString(Uint8List bytes) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < bytes.length;) {
      final int firstWord = (bytes[i] << 8) + bytes[i + 1];
      if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
        final int secondWord = (bytes[i + 2] << 8) + bytes[i + 3];
        buffer.writeCharCode(
            ((firstWord - 0xD800) << 10) + (secondWord - 0xDC00) + 0x10000);
        i += 4;
      } else {
        buffer.writeCharCode(firstWord);
        i += 2;
      }
    }

    // Outcome
    String outcome = buffer.toString();
    return outcome;
  }

  /// list 分割
  static List<List<T>> splitList<T>(List<T> list, int len) {
    if (len <= 1) {
      return [list];
    }

    final List<List<T>> result = [];
    int index = 1;

    while (true) {
      if (index * len < list.length) {
        final List<T> temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      final List<T> temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }

  // 位图转map
  static Map<String, bool> convNumToCatMap(int catNum) {
    final List<String> catList = EHConst.catList;
    final Map catsNumMaps = EHConst.cats;
    final Map<String, bool> catMap = <String, bool>{};
    for (int i = 0; i < catList.length; i++) {
      final String catName = catList[i];
      final int curCatNum = catsNumMaps[catName] as int;
      if (catNum & curCatNum != curCatNum) {
        catMap[catName] = true;
      } else {
        catMap[catName] = false;
      }
    }
    return catMap;
  }

  static int convCatMapToNum(Map<String, bool> catMap) {
    int totCatNum = 0;
    const Map<String, int> catsNumMaps = EHConst.cats;
    catMap.forEach((String key, bool value) {
      if (!value) {
        totCatNum += catsNumMaps[key] ?? 0;
      }
    });
    return totCatNum;
  }

  static List<Favcat> getFavListFromProfile() {
    final List<Favcat> favcatList = <Favcat>[];
    if (Global.profile.user.favcat != null) {
      for (final dynamic mapObj in Global.profile.user.favcat ?? []) {
        favcatList.add(mapObj as Favcat);
      }
    }

    return favcatList;
  }
}

class ColorsUtil {
  /// 十六进制颜色，
  /// hex, 十六进制值，例如：0xffffff,
  /// alpha, 透明度 [0.0,1.0]
  static Color hexColor(int hex, {double alpha = 1}) {
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    return Color.fromRGBO((hex & 0xFF0000) >> 16, (hex & 0x00FF00) >> 8,
        (hex & 0x0000FF) >> 0, alpha);
  }

  static Color? hexStringToColor(String? hexString, {double alpha = 1}) {
    // 如果传入的十六进制颜色值不符合要求，返回默认值
    if (hexString == null ||
        hexString.length != 7 ||
        int.tryParse(hexString.substring(1, 7), radix: 16) == null) {
      // s = '#999999';
      return null;
    }

    final int _hex =
        int.parse(hexString.substring(1, 7), radix: 16) + 0xFF000000;

    return hexColor(_hex, alpha: alpha);
  }

  static Color? getTagColor(String? hexColor) {
    if (hexColor != null && hexColor.isNotEmpty) {
      // logger.d(' $hexColor');
      return hexStringToColor(hexColor);
    }
    return null;
  }

  static bool isLight(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light;
  }
}

class WidgetUtil {
  static Rect getWidgetGlobalRect(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    return Rect.fromLTWH(offset.dx, offset.dy, renderBox?.size.width ?? 0.0,
        renderBox?.size.height ?? 0.0);
  }
}

class CookieUtil {
  static Future<void> resetExCookieFromEh() async {
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookiesEh =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EH_BASE_URL));
    final Cookie _memberId = Cookie.fromSetCookieValue(cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_member_id')
        .toString()
        .replaceAll('.e-hentai.org', '.exhentai.org'));
    final Cookie _passHash = Cookie.fromSetCookieValue(cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_pass_hash')
        .toString()
        .replaceAll('.e-hentai.org', '.exhentai.org'));

    cookieJar.delete(Uri.parse(EHConst.EX_BASE_URL));
    cookieJar.saveFromResponse(
        Uri.parse(EHConst.EX_BASE_URL), <Cookie>[_memberId, _passHash]);

    logger.d('cookiesEh\n' + cookiesEh.join('\n'));
  }

  static Future<void> fixEhCookie() async {
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookiesEh =
        await cookieJar.loadForRequest(Uri.parse(EHConst.EH_BASE_URL));
    final Cookie _memberId = cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_member_id')
      ..domain = '.e-hentai.org';
    final Cookie _passHash = cookiesEh
        .firstWhere((Cookie cookie) => cookie.name == 'ipb_pass_hash')
      ..domain = '.e-hentai.org';

    cookieJar.saveFromResponse(
        Uri.parse(EHConst.EH_BASE_URL), <Cookie>[_memberId, _passHash]);

    logger.d('cookiesEh\n' + cookiesEh.join('\n'));
  }
}

enum DohResolve {
  google,
  cloudflare,
}
