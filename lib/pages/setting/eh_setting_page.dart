import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EhSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EhSettingPage();
}

class _EhSettingPage extends State<EhSettingPage> {
  String _title = "EH设置";

  @override
  Widget build(BuildContext context) {
    CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewEhSetting(),
        ));

    return cps;
  }
}

class ListViewEhSetting extends StatelessWidget {
  ListViewEhSetting();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
//      itemCount: favItemBeans.length,

      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case (0):
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('显示中文Tag'),
                        Text(
                          '说明123456789',
                          style: TextStyle(
                              fontSize: 13, color: CupertinoColors.systemGrey),
                        ),
                      ]),
                  Expanded(
                    child: Container(),
                  ),
                  CupertinoSwitch(
                    onChanged: (bool value) {},
                    value: true,
                  )
                ],
              ),
            );
          case (1):
            return Container(
              height: 0.5,
              color: CupertinoColors.systemGrey4,
            );
          default:
            return null;
        }
      },
    );
  }
}
