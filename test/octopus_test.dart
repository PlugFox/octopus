import 'package:flutter_test/flutter_test.dart';

import 'src/hash_test.dart' as hash_test;
import 'src/state_test.dart' as state_test;

void main() {
  group('unit', () {
    state_test.main();
    hash_test.main();
  });
}
