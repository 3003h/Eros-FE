import 'dart:async';
import 'dart:io';

import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum ShowType {
  rename,
  create,
  delete,
}

class WebMySetting extends StatefulWidget {
  @override
  _WebMySettingState createState() => _WebMySettingState();
}

class _WebMySettingState extends State<WebMySetting> {
  WebViewController _controller;
  Future<void> _future;

  final TextEditingController _nameController = TextEditingController();

  Future<void> _getCookies() async {
    if (Api.getBaseUrl() == EHConst.EX_BASE_URL) {
      await CookieUtil.resetExCookieFromEh();
    }

    final WebviewCookieManager cookieManager = WebviewCookieManager();
    final List<Cookie> cookies =
        (await Api.cookieJar).loadForRequest(Uri.parse(Api.getBaseUrl()));
    // await cookieManager.clearCookies();
    logger.d(cookies.join('\n'));
    await cookieManager?.setCookies(cookies);
  }

  @override
  void initState() {
    super.initState();
    _future = _getCookies();
    // ignore: always_put_control_body_on_new_line
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  JavascriptChannel _deleteJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Delete',
        onMessageReceived: (JavascriptMessage message) {
          logger.d(message.message);
          if (message.message.contains('delete the profile')) {
            _showAlterDilog(ShowType.delete,
                defaultText: message.message, textField: false);
          }
        });
  }

  JavascriptChannel _promptJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Prompt',
        onMessageReceived: (JavascriptMessage message) {
          logger.d(message.message);
          final List<String> _msgs = message.message.split('#@#');
          final String _msg = _msgs[0];
          final String _defaultText = _msgs[1];
          if (_msg.contains('new name for this profile')) {
            logger.d('重命名 $_defaultText');
            _showAlterDilog(ShowType.rename, defaultText: _defaultText);
          } else if (_msg.contains('new profile')) {
            logger.d('新建配置 $_defaultText');
            _showAlterDilog(ShowType.create, defaultText: _defaultText);
          }
        });
  }

  Future<void> _showAlterDilog(
    ShowType type, {
    @required String defaultText,
    bool textField = true,
  }) {
    final String _title = type == ShowType.rename ? '重命名配置' : '新建配置';

    _nameController.value = TextEditingValue(
        // 设置内容
        text: defaultText,
        // 保持光标在最后
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: defaultText.length)));

    return showCupertinoDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(type != ShowType.delete ? _title : defaultText),
          content: Container(
            child: textField
                ? CupertinoTextField(
                    controller: _nameController,
                    autofocus: true,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    onEditingComplete: () {
                      // 点击键盘完成 提交
                      if (_nameController.text.trim().isNotEmpty) {
                        if (type == ShowType.rename) {
                          _renameProfile(_nameController.text.trim());
                        } else if (type == ShowType.create) {
                          _creatNewProfile(_nameController.text.trim());
                        } else if (type == ShowType.delete) {
                          _deleteProfile();
                        }
                        Get.back();
                      }
                    },
                  )
                : Container(),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                // 提交
                if (_nameController.text.trim().isNotEmpty) {
                  if (type == ShowType.rename) {
                    _renameProfile(_nameController.text.trim());
                  } else if (type == ShowType.create) {
                    _creatNewProfile(_nameController.text.trim());
                  } else if (type == ShowType.delete) {
                    _deleteProfile();
                  }
                  Get.back();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameProfile(String profileName) async {
    logger.d('rename to $profileName');
    try {
      final String javascript = '''
      document.getElementById("profile_action").value = "rename";
		  document.getElementById("profile_name").value = "$profileName";
		  do_profile_post();
      ''';
      // (await _controller.future)?.evaluateJavascript(javascript);
      _controller.evaluateJavascript(javascript);
    } catch (_) {}
  }

  Future<void> _creatNewProfile(String profileName) async {
    try {
      final String javascript = '''
      document.getElementById("profile_action").value = "create";
		  document.getElementById("profile_name").value = "$profileName";
		  do_profile_post();
      ''';
      // (await _controller.future)?.evaluateJavascript(javascript);
      _controller.evaluateJavascript(javascript);
    } catch (_) {}
  }

  Future<void> _deleteProfile() async {
    try {
      const String javascript = '''
      document.getElementById("profile_action").value = "delete";
		  do_profile_post();
      ''';
      // (await _controller.future)?.evaluateJavascript(javascript);
      _controller.evaluateJavascript(javascript);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 6),
          middle: const Text('Ehentai设置'),
          trailing: Container(
            width: 90,
            child: Row(
              children: <Widget>[
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.redo,
                    size: 20,
                  ),
                  onPressed: () async {
                    _controller.reload();
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.checkCircle,
                    size: 24,
                  ),
                  onPressed: () async {
                    _controller.evaluateJavascript(
                        'document.querySelector("#apply > input[type=submit]").click();');
                  },
                ),
              ],
            ),
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<void>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                } else {
                  return WebView(
                    initialUrl: '${Api.getBaseUrl()}/uconfig.php',
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: <JavascriptChannel>{
                      _promptJavascriptChannel(context),
                      _deleteJavascriptChannel(context),
                    },
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                    },
                    onPageStarted: (String url) {
                      print('Page started loading: $url');
                    },
                    onPageFinished: (String url) async {
                      print('Page Finished loading: $url');
                      // 重写 window.prompt和 window.confirm方法
                      try {
                        const String javascript = '''
                        window.prompt = function (msg,defaultText){
                          Prompt.postMessage(msg + '#@#' + defaultText);
                        }
                        window.confirm = function (msg){
                          Delete.postMessage(msg);
                        }
                        ''';
                        _controller?.evaluateJavascript(javascript);
                      } catch (_) {}
                    },
                    gestureNavigationEnabled: true,
                    navigationDelegate: (NavigationRequest request) {
                      if (!request.url.endsWith('/uconfig.php')) {
                        print('阻止打开 ${request.url}');
                        // _controller.loadUrl('${Api.getBaseUrl()}/uconfig.php');
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                  );
                }
              }),
        ));

    return cpf;
  }
}
