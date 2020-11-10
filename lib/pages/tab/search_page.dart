import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GallerySearchPage extends StatefulWidget {
  @override
  _GallerySearchPageState createState() => _GallerySearchPageState();
}

class _GallerySearchPageState extends State<GallerySearchPage> {
  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);

    Widget cfp = CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(start: 0),
//        border: null,
        backgroundColor: ThemeColors.navigationBarBackground,
        middle: CupertinoTextField(),
        transitionBetweenRoutes: false,
        previousPageTitle: '返回',
//        leading: CupertinoButton(
//          padding: const EdgeInsets.all(0),
//          child: const Text(
//            '关闭',
//          ),
//          onPressed: () {
//            Navigator.pop(context);
//          },
//        ),
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
