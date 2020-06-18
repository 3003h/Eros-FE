import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('用户登录'),
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(50, 40, 50, 20),
            child: Column(
              children: <Widget>[
                Container(
                  height: 38,
                  child: CupertinoTextField(
                    placeholder: '请输入账号',
                    prefix: Container(width: 50, child: Text('账号')),
                    decoration: null,
                  ),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.systemGrey4,
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(top: 10, bottom: 0),
                  child: CupertinoTextField(
                    placeholder: '请输入密码',
                    prefix: Container(width: 50, child: Text('密码')),
                    decoration: null,
                    obscureText: true,
                  ),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.systemGrey4,
                ),
              ],
            ),
          ),
        ));
  }
}
