import 'package:flutter_test/flutter_test.dart';
import 'package:octopus/octopus.dart';
import 'package:octopus/src/util/jenkins_hash.dart';

void main() => group('hash', () {
      test('list_equals', () {
        final list1 = <int>[1, 2, 3];
        final list2 = <int>[1, 2, 3];
        expect(list1, equals(list2));
        expect(jenkinsHash(list1), equals(jenkinsHash(list2)));
      });

      test('list_not_equals', () {
        final list1 = <int>[1, 2, 3];
        final list2 = <int>[1, 2, 4];
        expect(list1, isNot(equals(list2)));
        expect(jenkinsHash(list1), isNot(equals(jenkinsHash(list2))));
      });

      test('matrix_equals', () {
        final matrix1 = <List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5, 6]
        ];
        final matrix2 = <List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5, 6]
        ];
        expect(matrix1, equals(matrix2));
        expect(jenkinsHash(matrix1), equals(jenkinsHash(matrix2)));
      });

      test('matrix_not_equals', () {
        final matrix1 = <List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5, 6]
        ];
        final matrix2 = <List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5, 7]
        ];
        expect(matrix1, isNot(equals(matrix2)));
        expect(jenkinsHash(matrix1), isNot(equals(jenkinsHash(matrix2))));
      });

      test('map_equals', () {
        final map1 = <String, String>{'key': 'value'};
        final map2 = <String, String>{'key': 'value'};
        expect(map1, equals(map2));
        expect(jenkinsHash(map1), equals(jenkinsHash(map2)));
      });

      test('map_not_equals', () {
        final map1 = <String, String>{'key': 'value1'};
        final map2 = <String, String>{'key': 'value2'};
        expect(map1, isNot(equals(map2)));
        expect(jenkinsHash(map1), isNot(equals(jenkinsHash(map2))));
      });

      test('set_equals', () {
        final set1 = <int>{1, 2, 3};
        final set2 = <int>{1, 2, 3};
        expect(set1, equals(set2));
        expect(jenkinsHash(set1), equals(jenkinsHash(set2)));
      });

      test('set_not_equals', () {
        final set1 = <int>{1, 2, 3};
        final set2 = <int>{1, 2, 4};
        expect(set1, isNot(equals(set2)));
        expect(jenkinsHash(set1), isNot(equals(jenkinsHash(set2))));
      });

      test('node_equals', () {
        final node1 = OctopusNode.immutable(
          'name',
          arguments: {'key': 'value'},
          children: [
            OctopusNode.immutable(
              'child',
              arguments: {'a': 'b'},
            ),
          ],
        );
        final node2 = OctopusNode.immutable(
          'name',
          arguments: {'key': 'value'},
          children: [
            OctopusNode.immutable(
              'child',
              arguments: {'a': 'b'},
            ),
          ],
        );
        expect(node1, equals(node2));
        expect(jenkinsHash(node1), equals(jenkinsHash(node2)));
      });

      test('node_not_equals', () {
        final node1 = OctopusNode.immutable(
          'name',
          arguments: {'key': 'value1'},
          children: <OctopusNode>[
            OctopusNode.immutable(
              'child',
              arguments: {'a': 'b1'},
            ),
          ],
        );
        final node2 = OctopusNode.immutable(
          'name',
          arguments: {'key': 'value2'},
          children: <OctopusNode>[
            OctopusNode.immutable(
              'child',
              arguments: {'a': 'b2'},
            ),
          ],
        );
        expect(node1.hashCode, isNot(equals(node2.hashCode)));
        expect(node1, isNot(equals(node2)));
        expect(jenkinsHash(node1), isNot(equals(jenkinsHash(node2))));
      });
    });
