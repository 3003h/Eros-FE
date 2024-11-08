import 'dart:async';

import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';

Future<LoadBalancer> loadBalancer = LoadBalancer.create(4, IsolateRunner.spawn);

const kIdentifierCalculatePHash = 'calculatePHash';

class LoadBalancerHelper {
  static final Map<String, LoadBalancer> _instances = {};

  static Future<LoadBalancer> getInstance(String identifier, int size) async {
    if (!_instances.containsKey(identifier)) {
      _instances[identifier] =
          await LoadBalancer.create(size, IsolateRunner.spawn);
    }
    return _instances[identifier]!;
  }

  static Future<R> runTask<R, P>(
    String identifier,
    FutureOr<R> Function(P argument) function,
    P argument, {
    int size = 4,
  }) async {
    LoadBalancer loadBalancer = await getInstance(identifier, size);
    return loadBalancer.run(function, argument);
  }
}
