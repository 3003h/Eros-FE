import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';

Future<LoadBalancer> loadBalancer = LoadBalancer.create(4, IsolateRunner.spawn);
