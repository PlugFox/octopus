// ignore_for_file: unnecessary_lambdas

import 'package:flutter_test/flutter_test.dart';

import 'src/unit/hash_test.dart' as hash_test;
import 'src/unit/state_test.dart' as state_test;
import 'src/widget/observer_test.dart' as observer_test;

void main() {
  group('unit', () {
    state_test.main();
    hash_test.main();
  });

  group('widget', () {
    observer_test.main();
  });
}
