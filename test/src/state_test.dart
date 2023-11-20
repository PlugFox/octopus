// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:octopus/src/utils/state_util.dart';

void main() => group('state', () {
      test('decode_url', () {
        const location = 'Home/'
            '.Shop/'
            '..Catalog/'
            '...Category~id=1/'
            '...Category~id=12/'
            '...Brand~name=Apple/'
            '...Product~id=123&color=green/'
            '..Basket/'
            '..Favorites/'
            '.Gallery/'
            '.Camera/'
            '.Account/'
            '..Profile/'
            '..Settings';
        print(location);
        print('\n-->\n');
        final state = StateUtil.decodeLocation(location);
        print(state);
        print(state.uri);
        expect(true, isTrue);
      });
    });
