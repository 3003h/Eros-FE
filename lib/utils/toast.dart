import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' as oktoast;
import 'package:oktoast/oktoast.dart';

void showToast(String msg) {
//  Fluttertoast.showToast(
//      msg: msg,
//      toastLength: Toast.LENGTH_SHORT,
//      gravity: ToastGravity.BOTTOM, // 消息框弹出的位置
//      backgroundColor: Colors.grey,
//      textColor: Colors.white,
//      fontSize: 16.0);

  oktoast.showToast(
    msg,
    position: ToastPosition.bottom,
    backgroundColor: Color(0xaa000000),
  );
}
