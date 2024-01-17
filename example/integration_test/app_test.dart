import 'package:example/src/common/widget/app.dart';
import 'package:example/src/feature/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'src/fake/fake_dependencies.dart';
import 'src/util/tester_extension.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('end-to-end', () {
    late final Widget app;

    setUpAll(() async {
      binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
      final dependencies = await $initializeFakeDependencies();
      app = InheritedDependencies(
        dependencies: dependencies,
        child: const App(),
      );
    });

    testWidgets('app', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.byType(InheritedDependencies), findsOneWidget);
      expect(find.byType(App), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('sign-in', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text('Sign-In'), findsAtLeastNWidgets(1));
      await tester.tap(find.descendant(
        of: find.byType(InkWell),
        matching: find.text('Sign-Up'),
      ));
      await tester.pumpAndPause();
      await tester.tap(find.descendant(
        of: find.byType(InkWell),
        matching: find.text('Cancel'),
      ));
      await tester.pumpAndPause();
      await tester.enterText(
          find.ancestor(
            of: find.text('Username'),
            matching: find.byType(TextField),
          ),
          'app-test@gmail.com');
      await tester.enterText(
          find.ancestor(
            of: find.text('Password'),
            matching: find.byType(TextField),
          ),
          'Password123');
      await tester.tap(find.ancestor(
        of: find.byIcon(Icons.visibility),
        matching: find.byType(IconButton),
      ));
      await tester.pumpAndPause();
      await tester.tap(find.ancestor(
        of: find.byIcon(Icons.visibility_off),
        matching: find.byType(IconButton),
      ));
      await tester.pumpAndPause();
      await tester.tap(find.descendant(
        of: find.byType(InkWell),
        matching: find.text('Sign-In'),
      ));
      await tester.pumpAndPause(const Duration(seconds: 1));
      expect(find.text('Sign-In'), findsNothing);
      expect(find.text('Home'), findsAtLeastNWidgets(1));
    });
  });
}
