import 'package:flutter_test/flutter_test.dart';
import 'package:octopus/octopus.dart';

import 'fake_routes.dart';
import 'tester_extension.dart';

void main() => group('Observer', () {
      testWidgets(
        'value.children',
        (tester) async {
          final octopus = Octopus(routes: FakeRoutes.values);
          final controller = await tester.pumpApp(octopus);
          expect(
            octopus.observer.value.children,
            allOf(
              isNotEmpty,
              hasLength(1),
              contains(
                isA<OctopusNode>()
                    .having(
                      (node) => node.name,
                      'name',
                      FakeRoutes.home.name,
                    )
                    .having(
                      (node) => node.arguments,
                      'arguments',
                      isEmpty,
                    ),
              ),
            ),
          );
          await octopus.setState(
            (state) =>
                state..add(FakeRoutes.category.node(arguments: {'id': '1'})),
          );
          await controller.pump();
          expect(
            octopus.observer.value.children,
            allOf(
              isNotEmpty,
              hasLength(2),
            ),
          );
          await octopus.pop();
          expect(
            octopus.observer.value.children,
            allOf(
              isNotEmpty,
              hasLength(1),
              contains(
                isA<OctopusNode>().having(
                  (node) => node.name,
                  'name',
                  FakeRoutes.home.name,
                ),
              ),
            ),
          );
        },
      );

      testWidgets('addListener', (tester) async {
        final octopus = Octopus(routes: FakeRoutes.values);
        final controller = await tester.pumpApp(octopus);
        var calls = 0;
        var arguments = <String, String>{};
        octopus.observer.addListener(() {
          calls++;
          arguments = octopus.observer.value.arguments;
        });
        expect(calls, equals(0));
        await octopus.setState(
          (state) =>
              state..add(FakeRoutes.category.node(arguments: {'id': '1'})),
        );
        await controller.pump();
        expect(calls, equals(1));
        await octopus.pop();
        expect(calls, equals(2));
        expect(arguments, isEmpty);
        await octopus.setArguments((args) => args['name'] = 'Hello world');
        expect(calls, equals(3));
        expect(
          arguments,
          allOf(
            isNotEmpty,
            hasLength(1),
            containsPair('name', 'Hello world'),
          ),
        );
      });
    });
