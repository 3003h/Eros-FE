import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

Future<T?> showSimpleEhDiglog<T>({
  required BuildContext context,
  VoidCallback? onOk,
  String? title,
  String? contentText,
}) async {
  return await showCupertinoDialog<T>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(contentText ?? ''),
          actions: [
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: Get.back,
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
              onPressed: () {
                Get.back();
                onOk?.call();
              },
            ),
          ],
        );
      });
}
