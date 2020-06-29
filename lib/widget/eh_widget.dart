import 'package:flutter/cupertino.dart';

class TabPageTitle extends StatelessWidget {
  final bool isNotEmptyData;
  final String title;
  final String loadingText;

  TabPageTitle({this.isNotEmptyData, this.title, loadingText})
      : loadingText = loadingText ?? title;

  @override
  Widget build(BuildContext context) {
    return isNotEmptyData
        ? Text(
            title,
            style: TextStyle(fontFamilyFallback: ['JyuuGothic']),
          )
        : Container(
            child: Row(
              children: <Widget>[
                Text(
                  loadingText,
                  style: TextStyle(fontFamilyFallback: ['JyuuGothic']),
                ),
                Container(
                  width: 18,
                ),
                CupertinoActivityIndicator(
                  radius: 15.0,
                ),
              ],
            ),
          );
  }
}
