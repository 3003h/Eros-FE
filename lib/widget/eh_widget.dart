import 'package:flutter/cupertino.dart';

class TabPageTitle extends StatelessWidget {
  final bool isLoading;
  final String title;
  final String loadingText;

  TabPageTitle({this.isLoading = false, this.title, loadingText})
      : loadingText = loadingText ?? title;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            child: Row(
              children: <Widget>[
                Text(
                  loadingText,
                ),
                Container(
                  width: 18,
                ),
                const CupertinoActivityIndicator(
                  radius: 15.0,
                ),
              ],
            ),
          )
        : Text(
            title,
          );
  }
}
