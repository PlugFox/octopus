import 'package:flutter_test/flutter_test.dart';

import 'src/state_test.dart' as state_test;

void main() {
  group('unit', () {
    state_test.main();
    state_test.main(); // TODO(plugfox): remove this line
  });
}
