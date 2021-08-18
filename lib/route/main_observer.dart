import 'eh_observer.dart';

class MainNavigatorObserver extends EhNavigatorObserver {
  // 单例公开访问点
  factory MainNavigatorObserver() => _sharedInstance();

  // 私有构造函数
  MainNavigatorObserver._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static MainNavigatorObserver _sharedInstance() {
    _instance ??= MainNavigatorObserver._();
    return _instance!;
  }

  // 静态私有成员，没有初始化
  static MainNavigatorObserver? _instance;
}
