import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:flutter/material.dart';

/// 闪屏页
class SplashPage extends StatefulWidget {
  SplashPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    startHome();
  }

  startHome() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {
      NavigatorUtil.goHomePage(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Column(
            // center the children
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.local_cafe,
                // FontAwesomeIcons.heading,
                size: 150.0,
                color: Colors.grey,
              ),
              Text(
                S.of(context).welcome_text,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                S.of(context).app_title,
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
