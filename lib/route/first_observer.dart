import 'eh_observer.dart';

class FirstNavigatorObserver extends EhNavigatorObserver {
  // 单例公开访问点
  factory FirstNavigatorObserver() => _sharedInstance();

  // 私有构造函数
  FirstNavigatorObserver._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static FirstNavigatorObserver _sharedInstance() {
    _instance ??= FirstNavigatorObserver._();
    return _instance!;
  }

  // 静态私有成员，没有初始化
  static FirstNavigatorObserver? _instance;
}
