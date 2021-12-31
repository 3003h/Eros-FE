import 'package:flutter_test/flutter_test.dart';

void main() {
  test('n test', () {
    String? a = 'a';
    a = null;

    print('${a ?? 'b'}');
  });
}
