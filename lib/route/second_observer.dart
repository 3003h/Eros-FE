import 'eh_observer.dart';

class SecondNavigatorObserver extends EhNavigatorObserver {
  // 单例公开访问点
  factory SecondNavigatorObserver() => _sharedInstance();

  // 私有构造函数
  SecondNavigatorObserver._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static SecondNavigatorObserver _sharedInstance() {
    _instance ??= SecondNavigatorObserver._();
    return _instance!;
  }

  // 静态私有成员，没有初始化
  static SecondNavigatorObserver? _instance;
}
