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
        const location = '/';
        final state = StateUtil.decodeLocation(location);
        expect(state.location, equals(location));
        expect(state.uri, equals(Uri.parse(location)));
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

      test('decode_location_with_uuid', () {
        const id = '6e280140-5480-11ed-adf7-7f0a6d7e4482';
        const selected = 'about';
        const tabs = 'posts';
        const location = '/home'
            '/production~id=$id&selected=$selected'
            '?tabs=$tabs';
        final state = OctopusState.fromLocation(location);
        expect(state.children, hasLength(2));
        expect(state.arguments.keys, hasLength(1));
        expect(
            state.findByName('production'),
            isA<OctopusNode>()
                .having(
                  (e) => e.arguments['id'],
                  'id',
                  allOf(
                    isNotEmpty,
                    equals(id),
                  ),
                )
                .having(
                  (e) => e.arguments['selected'],
                  'selected',
                  allOf(
                    isNotEmpty,
                    equals(selected),
                  ),
                ));
        expect(state.arguments['tabs'], equals(tabs));
      });

      test('decode_url_to_state', () {
        const url = 'https://domain.tld/#/home/post-view~id=abc123';
        final state = OctopusState.fromUri(Uri(path: Uri.parse(url).fragment));
        expect(
          state.children.length,
          equals(2),
        );
      });
    });
