import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // 导入了Material UI组件库
import 'package:FEhViewer/utils/utility.dart';

class HttpTestRoute extends StatefulWidget {
  @override
  _HttpTestRouteState createState() => new _HttpTestRouteState();
}

class _HttpTestRouteState extends State<HttpTestRoute> {
  bool _loading = false;
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Http Test'),
        trailing: Icon(CupertinoIcons.add),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            CupertinoButton(
                child: Text("更新中文Tag翻译"),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                          _text = "正在请求...";
                        });

                        try {
                          _text = await EHUtils.generateTagTranslat();
                        } catch (e) {
                          _text = "请求失败：$e";
                          throw e;
                        } finally {
                          setState(() {
                            _loading = false;
                          });
                        }
                      }),
            Container(
                width: MediaQuery.of(context).size.width - 50.0,
                child: Text(_text))
          ]),
        ),
      ),
    );
  }
}
