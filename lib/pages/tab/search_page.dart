import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class GallerySearchPage extends StatefulWidget {
  @override
  _GallerySearchPageState createState() => _GallerySearchPageState();
}

class _GallerySearchPageState extends State<GallerySearchPage> {
  // 搜索内容的控制器
  final TextEditingController _searchTextController = TextEditingController();

  void _jumpSearch() {
    final String _searchText = _searchTextController.text;
    final int _catNum =
        Provider.of<EhConfigModel>(context, listen: false).catFilter;
    if (_searchText.isNotEmpty) {
      NavigatorUtil.goGalleryList(
        context,
        simpleSearch: _searchText,
        cats: _catNum,
        replace: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);

    final Widget cfp = CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
//        border: null,
        backgroundColor: ThemeColors.navigationBarBackground,
        middle: CupertinoTextField(
          controller: _searchTextController,
          onEditingComplete: () {
            // 点击键盘完成
            _jumpSearch();
          },
        ),
        transitionBetweenRoutes: false,
        previousPageTitle: '返回',
        trailing: Container(
          width: 90,
          child: Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.search,
                  size: 20,
                ),
                onPressed: () {
                  Global.logger.v('search Btn');
                  _jumpSearch();
                },
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.filter,
                  size: 20,
                ),
                onPressed: () {
                  GalleryBase().setCats(context);
                },
              ),
            ],
          ),
        ),
      ),
      child: CustomScrollView(),
    );

    return cfp;
  }
}
