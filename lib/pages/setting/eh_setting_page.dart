import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/common/tag_database.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/pages/login/web_mysetting.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'setting_base.dart';

class EhSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EhSettingPage();
}

class _EhSettingPage extends State<EhSettingPage> {
  final String _title = 'EH设置';

  Future<bool> _getDelayed() async {
    final int _delayed = (Global.isFirstReOpenEhSetting ?? true) ? 200 : 1;
    // logger.v('$_delayed');
    await Future<void>.delayed(Duration(milliseconds: _delayed));
    Global.isFirstReOpenEhSetting = false;
    return Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: FutureBuilder<bool>(
              future: _getDelayed(),
              builder: (_, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListViewEhSetting();
                  // return Container();
                } else {
                  return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 50, bottom: 100),
                      child: const CupertinoActivityIndicator(
                        radius: 14,
                      ));
                }
              }),
        ));

    return cps;
  }
}

class ListViewEhSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EhConfigController ehConfigController = Get.find();

    final bool _siteEx = ehConfigController.isSiteEx.value;
    final bool _jpnTitle = ehConfigController.isJpnTitle.value;
    final bool _tagTranslat = ehConfigController.isTagTranslat.value;
    final bool _galleryImgBlur = ehConfigController.isGalleryImgBlur.value;
    final bool _favLongTap = ehConfigController.isFavLongTap.value;
    final bool _favOrder =
        ehConfigController.favoriteOrder.value == FavoriteOrder.posted;
    final bool _isLogin =
        Provider.of<UserModel>(context, listen: false).isLogin;

    Future<void> _handleSiteChanged(bool newValue) async {
      ehConfigController.isSiteEx(newValue);
    }

    void _handleJpnTitleChanged(bool newValue) {
      ehConfigController.isJpnTitle(newValue);
    }

    /// 打开表示按更新时间排序 关闭表示按照收藏时间排序
    void _handleFavOrderChanged(bool newValue) {
      ehConfigController.favoriteOrder.value =
          newValue ? FavoriteOrder.posted : FavoriteOrder.fav;
    }

    void _handleTagTranslatChanged(bool newValue) {
      ehConfigController.isTagTranslat.value = newValue;
      if (newValue) {
        try {
          EhTagDatabase.generateTagTranslat();
        } catch (e) {
          debugPrint('更新翻译异常 $e');
        }
      }
    }

    void _handleGalleryListImgBlurChanged(bool newValue) {
      ehConfigController.isGalleryImgBlur.value = newValue;
    }

    void _handleFavLongTapChanged(bool newValue) {
      ehConfigController.isFavLongTap.value = newValue;
    }

    final List<Widget> _list = <Widget>[
      if (_isLogin)
        TextSwitchItem(
          '站点切换',
          intValue: _siteEx,
          onChanged: _handleSiteChanged,
          desc: '当前E-Hentai',
          descOn: '当前ExHentai',
        ),
      if (_isLogin)
        SelectorSettingItem(
          title: 'Ehentai设置',
          selector: '网站设置',
          onTap: () {
            Get.to(WebMySetting());
          },
        ),
      if (_isLogin)
        Divider(
          height: 38,
          thickness: 38.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey5, context),
        ),
      Obx(() => TextSwitchItem('显示标签中文翻译',
          intValue: _tagTranslat,
          onChanged: _handleTagTranslatChanged,
          desc:
              '需要下载数据文件,当前版本:${ehConfigController.tagTranslatVer.value ?? "无"}')),
      TextSwitchItem('显示日文标题',
          intValue: _jpnTitle,
          onChanged: _handleJpnTitleChanged,
          desc: '如果该画廊有日文标题则优先显示'),
      TextSwitchItem('画廊封面模糊',
          intValue: _galleryImgBlur,
          onChanged: _handleGalleryListImgBlurChanged,
          desc: '画廊列表封面模糊效果'),
      Divider(
        height: 38,
        thickness: 38.5,
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey5, context),
      ),
      TextSwitchItem(
        '默认收藏夹设置',
        intValue: _favLongTap,
        onChanged: _handleFavLongTapChanged,
        desc: '无默认,每次进行选择',
        descOn: '使用上次选择，长按选择其他',
      ),
      TextSwitchItem(
        '收藏夹排序方式',
        intValue: _favOrder,
        onChanged: _handleFavOrderChanged,
        desc: '按收藏时间排序',
        descOn: '按更新时间排序',
      ),
      _buildListModeItem(context),
      _buildHistoryMaxItem(context),
    ];

    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 列表模式切换
Widget _buildListModeItem(BuildContext context) {
  const String _title = '浏览模式';
  final EhConfigController ehConfigController = Get.find();

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.list: '列表 - 中',
    ListModeEnum.simpleList: '列表 - 小',
    ListModeEnum.waterfall: '瀑布流',
  };

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(modeMap.keys.map((ListModeEnum element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element]));
    }).toList());
  }

  Future<ListModeEnum> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<ListModeEnum>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            // title: const Text('列表模式选择'),
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

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector:
            modeMap[ehConfigController.listMode.value ?? ListModeEnum.list],
        onTap: () async {
          logger.v('tap ModeItem');
          final ListModeEnum _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigController.listMode.value = _result;
          }
        },
      ));
}

/// 历史记录数量切换
Widget _buildHistoryMaxItem(BuildContext context) {
  const String _title = '最大历史记录数';
  final EhConfigController ehConfigController = Get.find();

  String _getMaxNumText(int max) {
    if (max == 0) {
      return '无限制';
    } else {
      return '$max';
    }
  }

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(EHConst.historyMax.map((int element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(_getMaxNumText(element)));
    }).toList());
  }

  Future<int> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            // title: const Text('列表模式选择'),
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

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: _getMaxNumText(ehConfigController.maxHistory.value) ?? '',
        onTap: () async {
          logger.v('tap ModeItem');
          final int _result = await _showActionSheet(context);
          if (_result != null) {
            ehConfigController.maxHistory.value = _result;
          }
        },
      ));
}
