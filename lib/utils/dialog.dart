import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

Future<T?> showSimpleEhDiglog<T>({
  required BuildContext context,
  VoidCallback? onOk,
  String? title,
  String? contentText,
  Widget? content,
  TextAlign textAlign = TextAlign.start,
  bool autoClose = true,
}) async {
  return await showCupertinoDialog<T>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: title != null ? Text(title) : null,
          content: content ??
              Text(
                contentText ?? '',
                textAlign: textAlign,
              ),
          actions: [
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: Get.back,
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
              onPressed: () {
                if (autoClose) {
                  Get.back();
                }
                return onOk?.call();
              },
            ),
          ],
        );
      });
}

Future<Uri?> showSAFPermissionRequiredDialog({
  bool loop = false,
  required Uri uri,
  String contentText = 'Please grant permission to access the path',
}) async {
  Future<Uri?> _showDialog() async {
    return await showSimpleEhDiglog<Uri?>(
      context: Get.overlayContext!,
      contentText: contentText,
      autoClose: false,
      onOk: () async {
        final resultUri = await ss.openDocumentTree(initialUri: uri);
        Get.back(result: resultUri);
      },
    );
  }

  if (loop) {
    while (!(await ss.isPersistedUri(uri))) {
      return await _showDialog();
    }
  } else {
    if (!(await ss.isPersistedUri(uri))) {
      return await _showDialog();
    }
  }
  return null;
}
