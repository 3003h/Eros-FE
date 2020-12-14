import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/pages/setting/setting_base.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DownloadSettingPage extends StatefulWidget {
  @override
  _DownloadSettingPageState createState() => _DownloadSettingPageState();
}

class _DownloadSettingPageState extends State<DownloadSettingPage> {
  final String _title = '下载设置';
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: true,
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewDownloadSetting(),
        ));

    return cps;
  }
}

class ListViewDownloadSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      _buildPreloadImageItem(context),
    ];
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 预载图片数量
Widget _buildPreloadImageItem(BuildContext context) {
  const String _title = '预载图片数量';
  final EhConfigModel ehConfigModel =
      Provider.of<EhConfigModel>(context, listen: false);

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(EHConst.preloadImage.map((int element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text('$element'));
    }).toList());
  }

  Future<int> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: const Text('取消')),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Selector<EhConfigModel, int>(
      selector: (BuildContext context, EhConfigModel ehConfigModel) =>
          ehConfigModel.preloadImage,
      builder: (BuildContext context, int preloadImage, _) {
        return SelectorSettingItem(
          title: _title,
          selector: preloadImage?.toString() ?? '',
          onTap: () async {
            final int _result = await _showActionSheet(context);
            if (_result != null) {
              ehConfigModel.preloadImage = _result;
            }
          },
        );
      });
}
