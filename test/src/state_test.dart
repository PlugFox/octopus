// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/util/state_util.dart';

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
        expect(() => StateUtil.decodeLocation(location), returnsNormally);
        /* print('$location\n'
            '-->\n'
            '${StateUtil.decodeLocation(location).toString()}'); */
      });

      test('empty_url', () {
        const location = '';
        final state = StateUtil.decodeLocation(location);
        expect(state.location, equals(location));
        expect(state.uri, equals(Uri.parse(location)));
        expect(state.uri, equals(Uri()));
        expect(state.arguments, isEmpty);
        expect(state, equals(OctopusState.empty()));
      });

      test('encode_and_decode_cyrillic_location', () {
        final sourceState = OctopusState.fromJson(<String, Object?>{
          'children': <Object?>[
            <String, Object?>{
              'name': 'route',
              'arguments': {'text': 'Привет мир'},
            }
          ],
        });
        final encodedLocation =
            StateUtil.encodeLocation(sourceState).toString();
        final decodedState = StateUtil.decodeLocation(encodedLocation);
        expect(decodedState, equals(sourceState));
        expect(
          decodedState.children.single.arguments,
          equals(
            {
              'text': 'Привет мир',
            },
          ),
        );
      });

      test('decode_and_encode_cyrillic_state', () {
        const location =
            'route~name=Привет мир?теплое=Мягкое&Вкусное=кислое&флаг';
        final state = StateUtil.decodeLocation(location);
        expect(state.children, hasLength(1));
        expect(
          state.children.single,
          isA<OctopusNode>()
              .having(
                (e) => e.name,
                'name',
                allOf(
                  isNotEmpty,
                  equals('route'),
                ),
              )
              .having(
                (e) => e.arguments,
                'arguments',
                allOf(
                  isNotEmpty,
                  equals(
                    {
                      'name': 'Привет мир',
                    },
                  ),
                ),
              ),
        );
        expect(state.arguments['теплое'], equals('Мягкое'));
        expect(state.arguments['Вкусное'], equals('кислое'));
        expect(state.arguments['флаг'], isEmpty);
        expect(() => state.location, returnsNormally);
      });
    });
