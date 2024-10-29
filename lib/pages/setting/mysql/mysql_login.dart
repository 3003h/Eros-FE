import 'package:eros_fe/common/controller/mysql_controller.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

const TextStyle kTextStyle = TextStyle(
  fontSize: 18,
  textBaseline: TextBaseline.alphabetic,
  height: 1.2,
);

class MysqlLogin extends StatefulWidget {
  const MysqlLogin({super.key});

  @override
  State<MysqlLogin> createState() => _MysqlLoginState();
}

class _MysqlLoginState extends State<MysqlLogin> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _databaseController = TextEditingController();
  final _userController = TextEditingController();
  final _pwdController = TextEditingController();

  final _nodePort = FocusNode();
  final _nodeDatabase = FocusNode();
  final _nodeUser = FocusNode();
  final _nodePwd = FocusNode();

  late bool _obscurePasswd;
  bool _loadingLogin = false;

  MysqlController get controller => Get.find<MysqlController>();

  @override
  void initState() {
    super.initState();
    _obscurePasswd = true;

    _hostController.text = controller.connectionInfo?.host ?? '';
    _portController.text = controller.connectionInfo?.port.toString() ?? '';
    _databaseController.text = controller.connectionInfo?.databaseName ?? '';
    _userController.text = controller.connectionInfo?.userName ?? '';
    _pwdController.text = controller.connectionInfo?.password ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final _placeholderStyle = kTextStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: CupertinoColors.placeholderText,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('MySQL Login'),
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: MultiSliver(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 30),
                  child: Icon(
                    FontAwesomeIcons.database,
                    size: 120,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                CupertinoFormSection.insetGrouped(
                  // margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: _hostController,
                      style: kTextStyle,
                      placeholderStyle: _placeholderStyle,
                      placeholder: 'Host',
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_nodePort);
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      controller: _portController,
                      focusNode: _nodePort,
                      style: kTextStyle,
                      placeholderStyle: _placeholderStyle,
                      placeholder: 'Port',
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_nodeDatabase);
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      controller: _databaseController,
                      focusNode: _nodeDatabase,
                      style: kTextStyle,
                      placeholderStyle: _placeholderStyle,
                      placeholder: 'Database',
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_nodeUser);
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      controller: _userController,
                      focusNode: _nodeUser,
                      style: kTextStyle,
                      placeholderStyle: _placeholderStyle,
                      placeholder: 'Username',
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_nodePwd);
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      controller: _pwdController,
                      focusNode: _nodePwd,
                      style: kTextStyle,
                      placeholderStyle: _placeholderStyle,
                      placeholder: 'Password',
                      obscureText: _obscurePasswd,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        minSize: 100,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        color: CupertinoColors.activeBlue,
                        onPressed: _loadingLogin
                            ? null
                            : () async {
                                setState(() {
                                  _loadingLogin = true;
                                });

                                if (_hostController.text.isEmpty ||
                                    _portController.text.isEmpty ||
                                    _databaseController.text.isEmpty ||
                                    _userController.text.isEmpty ||
                                    _pwdController.text.isEmpty) {
                                  // Get.snackbar(
                                  //   'Error',
                                  //   'Please fill in all the information',
                                  //   snackPosition: SnackPosition.BOTTOM,
                                  //   margin: const EdgeInsets.all(10),
                                  //   backgroundColor:
                                  //       CupertinoDynamicColor.resolve(
                                  //           CupertinoColors.systemRed, context),
                                  //   colorText: CupertinoColors.white,
                                  // );
                                  showToast(
                                      'Please fill in all the information');
                                  setState(() {
                                    _loadingLogin = false;
                                  });
                                  return;
                                }

                                try {
                                  logger.d('loginMySQL');
                                  final result = await controller.loginMySQL(
                                    connectionInfo: MySQLConnectionInfo(
                                      host: _hostController.text,
                                      port: int.parse(_portController.text),
                                      databaseName: _databaseController.text,
                                      userName: _userController.text,
                                      password: _pwdController.text,
                                    ),
                                  );
                                  if (result != null && result) {
                                    Get.back(id: isLayoutLarge ? 2 : null);
                                  }
                                } finally {
                                  setState(() {
                                    _loadingLogin = false;
                                  });
                                }
                              },
                        child: _loadingLogin
                            ? const CupertinoActivityIndicator()
                            : Text(L10n.of(context).login),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
