import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/pages/gallery/controller/archiver_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kIconSize = 16.5;

class ArchiverView extends StatelessWidget {
  const ArchiverView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ArchiverController controller = Get.find(tag: pageCtrlTag);

    final Map<String, String> typedesc = {
      'res': 'Resample Archive',
      'org': 'Original Archive',
    };

    return controller.obx(
      (ArchiverProvider? state) {
        return Column(
          children: <Widget>[
            if (state?.gp?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.all(8.0),
                // child: Text('G ${state.gp}   C ${state.credits}'),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Container(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: CupertinoDynamicColor.resolve(
                                    CupertinoColors.secondarySystemBackground,
                                    context),
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                fontSize: 10,
                              ),
                            ),
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                            width: kIconSize,
                            height: kIconSize,
                            alignment: Alignment.center,
                          ),
                        ).paddingSymmetric(horizontal: 4.0),
                        Text(state?.gp ?? ''),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Container(
                            child: Text(
                              'C',
                              style: TextStyle(
                                color: CupertinoDynamicColor.resolve(
                                    CupertinoColors.secondarySystemBackground,
                                    context),
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                fontSize: 10,
                              ),
                            ),
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                            width: kIconSize,
                            height: kIconSize,
                            alignment: Alignment.center,
                          ),
                        ).paddingSymmetric(horizontal: 4.0),
                        Text(state?.credits ?? ''),
                      ],
                    ),
                  ],
                ),
              ),
            // if (Global.inDebugMode)
            if (GetPlatform.isMobile)
              const Text(
                'Download',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            // if (Global.inDebugMode)
            if (GetPlatform.isMobile)
              Container(
                padding: const EdgeInsets.only(top: 4.0),
                height: 100,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (_, int index) {
                    final ArchiverProviderItem? _item = state?.dlItems?[index];
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          Text(typedesc[_item?.dltype] ?? '')
                              .paddingOnly(bottom: 2.0),
                          Text(
                            '${_item?.size ?? ''}    ${_item?.price ?? ''}',
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
                        if (_item == null) {
                          return;
                        }
                        controller.downloadLoacal(
                            dltype: _item.dltype ?? '',
                            dlcheck: typedesc[_item.dltype] ?? '');
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
                  itemCount: state?.dlItems?.length ?? 0,
                ),
              ),
            const Text(
              'H@H',
              style: TextStyle(fontWeight: FontWeight.bold),
            ).paddingOnly(top: 8.0),
            HatHGridView(
              controller: controller,
              state: state,
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

class HatHListView extends StatelessWidget {
  const HatHListView({
    Key? key,
    required this.controller,
    required this.state,
  }) : super(key: key);

  final ArchiverController controller;
  final ArchiverProvider? state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      height: (state?.hItems?.length ?? 0) * 40 + 50.0,
      child: ListView.separated(
        padding: const EdgeInsets.all(0),
        itemBuilder: (_, int index) {
          final ArchiverProviderItem? _item = state?.hItems?[index];
          return CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: <Widget>[
                Text(_item?.resolution ?? '').paddingOnly(bottom: 2.0),
                Text(
                  '${_item?.size ?? ''}    ${_item?.price ?? ''}',
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
              controller.downloadRemote(_item!.dlres!);
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
        itemCount: state?.hItems?.length ?? 0,
      ),
    );
  }
}

class HatHGridView extends StatelessWidget {
  const HatHGridView({
    Key? key,
    required this.controller,
    required this.state,
  }) : super(key: key);

  final ArchiverController controller;
  final ArchiverProvider? state;

  @override
  Widget build(BuildContext context) {
    final List<Widget>? _items = state?.hItems!
        .map((_item) => CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Text(_item.resolution ?? '').paddingOnly(bottom: 2.0),
                  Text(
                    '${_item.size}   ${_item.price}',
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
                controller.downloadRemote(_item.dlres!);
                Get.back();
              },
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      height: ((state?.hItems?.length ?? 0) / 2).round() * 55.0,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 2.0,
        children: _items!,
      ),
    );
  }
}

Future<void> showArchiverDialog() {
  // Get.put(ArchiverController(), tag: pageCtrlDepth);
  return showCupertinoDialog<void>(
      context: Get.overlayContext!,
      barrierDismissible: true,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(L10n.of(Get.context!).p_Archiver),
          content: Container(
            child: const ArchiverView(),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(Get.context!).cancel),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      });
}
