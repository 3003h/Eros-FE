import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 列表加载异常时的默认页面
/// 包含一个点击回调 可用于触发重载
class GalleryErrorPage extends StatelessWidget {
  const GalleryErrorPage({Key key, this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoButton(
        onPressed: onTap,
        child: Icon(
          FontAwesomeIcons.syncAlt,
          size: 50,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey, context),
        ),
      ),
    );
  }
}
