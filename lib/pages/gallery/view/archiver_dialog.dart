import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArchiverView extends StatelessWidget {
  const ArchiverView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ArchiverController controller = Get.find(tag: pageCtrlDepth);

    final Map<String, String> typedesc = {
      'res': 'Resample Archive',
      'org': 'Original Archive',
    };

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
            if (Global.inDebugMode)
              const Text(
                'Download',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (Global.inDebugMode)
              Container(
                padding: const EdgeInsets.only(top: 4.0),
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (_, int index) {
                    final ArchiverProviderItem _item = state.dlItems[index];
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          Text(typedesc[_item.dltype]).paddingOnly(bottom: 2.0),
                          Text(
                            '${_item.size}    ${_item.price}',
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
                        controller.downloadLoacal(
                            dltype: _item.dltype,
                            dlcheck: typedesc[_item.dltype]);
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
                  itemCount: state.dlItems?.length ?? 0,
                ),
              ),
            const Text(
              'H@H',
              style: TextStyle(fontWeight: FontWeight.bold),
            ).paddingOnly(top: 8.0),
            Container(
              padding: const EdgeInsets.only(top: 4.0),
              height: (state.hItems?.length ?? 0) * 40 + 50.0,
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (_, int index) {
                  final ArchiverProviderItem _item = state.hItems[index];
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: <Widget>[
                        Text(_item.resolution).paddingOnly(bottom: 2.0),
                        Text(
                          '${_item.size}    ${_item.price}',
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      controller.downloadRemote(_item.dlres);
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
                itemCount: state.hItems?.length ?? 0,
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
  // Get.put(ArchiverController(), tag: pageCtrlDepth);
  return showCupertinoDialog<void>(
      context: Get.overlayContext,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(S.of(Get.context).p_Archiver),
          content: Container(
            child: const ArchiverView(),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(Get.overlayContext).cancel),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      });
}
