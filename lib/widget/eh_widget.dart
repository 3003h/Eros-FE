import 'package:flutter/cupertino.dart';

class TabPageTitle extends StatelessWidget {
  final bool isLoading;
  final String title;
  final String loadingText;

  TabPageTitle({this.isLoading, this.title, loadingText})
      : loadingText = loadingText ?? title;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
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
          )
        : Text(
            title,
            style: TextStyle(fontFamilyFallback: ['JyuuGothic']),
          );
  }
}
