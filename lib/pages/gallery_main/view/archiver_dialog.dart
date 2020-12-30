import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery_main/controller/archiver_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArchiverView extends StatelessWidget {
  const ArchiverView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ArchiverController controller = Get.find(tag: pageCtrlDepth);
    return controller.obx(
      (ArchiverProvider state) {
        return Column(
          children: <Widget>[
            if (state.gp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Current funds:\n GP: ${state.gp}   Credits: ${state.credits}'),
              ),
            const Text(
              'H@H',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              height: (state.items?.length ?? 0) * 40 + 50.0,
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (_, int index) {
                  final ArchiverProviderItem _item = state.items[index];
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: <Widget>[
                        Text(_item.resolution),
                        Text(
                          '${_item.size}, ${_item.price}',
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      // logger.d('tap $index');
                      controller.download(_item.dlres);
                      // Get.delete<ArchiverController>(tag: pageCtrlDepth);
                      Get.back();
                    },
                  );
                },
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 0.5,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                  );
                },
                itemCount: state.items?.length ?? 0,
              ),
            ),
          ],
        );
      },
      onLoading: Container(
        margin: const EdgeInsets.all(10.0),
        child: const CupertinoActivityIndicator(
          radius: 14,
        ),
      ),
      onError: (err) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.red,
                ),
                onPressed: () {
                  controller.reload();
                },
              ),
              const Text(
                'Error',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showArchiverDialog() {
  Get.put(ArchiverController(), tag: pageCtrlDepth);
  return showCupertinoDialog<void>(
      context: Get.overlayContext,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('Archiver'),
          content: Container(
            child: const ArchiverView(),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(Get.overlayContext).cancel),
              onPressed: () {
                // Get.delete<ArchiverController>(tag: pageCtrlDepth);
                Get.back();
              },
            ),
          ],
        );
      });
}
