import 'package:flutter_test/flutter_test.dart';

import 'src/state_test.dart' as state_test;

void main() {
  group('unit', () {
    test('placeholder', () {
      expect(true, isTrue);
    });
    state_test.main();
  });
}
