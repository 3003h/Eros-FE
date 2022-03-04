import 'package:flutter_test/flutter_test.dart';

Function a = ({required int a, int b = 1}) => a + b;

void main() {
  test('n test', () {
    print(a(a: 1, b: 3));
  });
}
