import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'webview/web_mysetting_in.dart';

class EhMySettingsPage extends StatelessWidget {
  const EhMySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).ehentai_settings),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    LineIcons.globeWithAmericasShown,
                    size: 24,
                  ),
                  onPressed: () async {
                    Get.to(() => InWebMySetting());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    LineIcons.checkCircle,
                    size: 24,
                  ),
                  onPressed: () async {
                    // 保存配置
                  },
                ),
              ],
            )),
        child: SafeArea(
          child: ListViewEhMySettings(),
          bottom: false,
        ));
  }
}

class ListViewEhMySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      _GroupHeader(
        text: 'Image Load Settings',
      ),
      _buildLoadTypeItem(context),
      _GroupHeader(
        text: 'Image Size Settings',
      ),
      _buildImageSizeItem(context),
      _GroupHeader(
        text: 'Gallery Name Display',
      ),
      _buildNameDisplayItem(context),
      _GroupHeader(
        text: 'Archiver Settings',
      ),
      _GroupHeader(
        text: 'Front Page Settings',
      ),
      _GroupHeader(
        text: 'Favorites',
      ),
      _GroupHeader(
        text: 'Ratings',
      ),
      _GroupHeader(
        text: 'Tag Namespaces',
      ),
      _GroupHeader(
        text: 'Tag Filtering Threshold',
      ),
      _GroupHeader(
        text: 'Tag Watching Threshold',
      ),
      _GroupHeader(
        text: 'Excluded Languages',
      ),
      _GroupHeader(
        text: 'Excluded Uploaders',
      ),
      _GroupHeader(
        text: 'Search Result Count',
      ),
      _GroupHeader(
        text: 'Thumbnail Settings',
      ),
      _GroupHeader(
        text: 'Thumbnail Scaling',
      ),
      _GroupHeader(
        text: 'Viewport Override',
      ),
      _GroupHeader(
        text: 'Gallery Comments',
      ),
      _GroupHeader(
        text: 'Gallery Tags',
      ),
      _GroupHeader(
        text: 'Gallery Page Numbering',
      ),
      _GroupHeader(
        text: 'Hentai@Home Local Network Host',
      ),
      _GroupHeader(
        text: 'Original Images',
      ),
      _GroupHeader(
        text: 'Multi-Page Viewer',
      ),
    ];

    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

Widget _buildLoadTypeItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> modeMap = <String, String>{
    '0': 'Any client (Recommended)',
    '1':
        'Default port clients only (Can be slower. Enable if behind firewall/proxy that blocks outgoing non-standard ports.)',
    '2':
        'No (Donator only. You will not be able to browse as many pages, enable only if having severe problems.)',
  };

  final Map<String, String> actionMap = <String, String>{
    '0': 'Any client',
    '1': 'Default port clients only',
    '2': 'No',
  };
  return SelectorItem<String>(
    title: 'Load images through the H@H',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: '',
    onValueChanged: (val) => print(val),
  );
}

Widget _buildImageSizeItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Auto',
    '5': '2400x',
    '4': '1600x',
    '3': '1280x',
    '2': '980x',
    '1': '780x',
  };
  return SelectorItem<String>(
    title: 'Resample Resolution',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: '',
    onValueChanged: (val) => print(val),
  );
}

Widget _buildNameDisplayItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Default Title',
    '1': 'Japanese Title',
  };
  return SelectorItem<String>(
    title: 'Name Display',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: '',
    onValueChanged: (val) => print(val),
  );
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({Key? key, this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.only(left: 20, bottom: 4),
      alignment: Alignment.bottomLeft,
      child: Text(
        text ?? '',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
