
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String msg){
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,  // 消息框弹出的位置
      // backgroundColor: Colors.grey,
      // textColor: Colors.white,
      fontSize: 16.0
    );
}