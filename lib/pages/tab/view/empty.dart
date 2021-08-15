import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      child: Container(
        child: const Center(
          child: Icon(
            FontAwesomeIcons.layerGroup,
            size: 100,
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
    );
  }
}
