import 'package:eros_fe/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 列表加载异常时的默认页面
/// 包含一个点击回调 可用于触发重载
class GalleryErrorPage extends StatelessWidget {
  const GalleryErrorPage({Key? key, this.onTap, this.error}) : super(key: key);
  final VoidCallback? onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          onPressed: onTap,
          child: Icon(
            randomList<IconData>([
              FontAwesomeIcons.grinBeamSweat,
              FontAwesomeIcons.sadTear,
              FontAwesomeIcons.tired,
              FontAwesomeIcons.surprise,
            ]),
            size: 50,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey, context),
          ),
        ),
        Text(
          error ?? '',
          textScaler: const TextScaler.linear(0.9),
        ),
      ],
    );
  }
}
