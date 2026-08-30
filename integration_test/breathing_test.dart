import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';
import 'helpers/seed.dart';

void breathingTests() {
  registerAppHarnessTearDown();

  Future<void> openBreathing(
    WidgetTester tester, {
    Seed seed = const Seed.demo(),
  }) async {
    await launchApp(tester, seed: seed);
    await tester.tap(findTab('Breathing'));
    await tester.pumpAndSettle();
  }

  group('Breathing exercises', () {
    testWidgets('lists seeded exercises with their pattern', (tester) async {
      await openBreathing(tester);

      expect(find.text('Square breathing'), findsOneWidget);
      expect(find.text('In 4 - Hold 4 - Out 4 - Hold 4'), findsOneWidget);
    });

    testWidgets('creates an exercise', (tester) async {
      await openBreathing(tester);

      await tester.tap(find.byTooltip('Create breathing exercise'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'IT exercise');
      await tester.enterText(find.byType(TextFormField).at(1), '4');
      await tester.enterText(find.byType(TextFormField).at(2), '0');
      await tester.enterText(find.byType(TextFormField).at(3), '4');
      await tester.enterText(find.byType(TextFormField).at(4), '0');
      await tester.enterText(find.byType(TextFormField).at(5), '3');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('IT exercise'), findsOneWidget);
    });

    testWidgets('rejects a non-integer count', (tester) async {
      await openBreathing(tester);

      await tester.tap(find.byTooltip('Create breathing exercise'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Bad exercise');
      await tester.enterText(find.byType(TextFormField).at(1), 'abc');
      await tester.enterText(find.byType(TextFormField).at(2), '0');
      await tester.enterText(find.byType(TextFormField).at(3), '4');
      await tester.enterText(find.byType(TextFormField).at(4), '0');
      await tester.enterText(find.byType(TextFormField).at(5), '3');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Count In must be an integer'), findsOneWidget);
    });

    testWidgets('edits and deletes an exercise', (tester) async {
      await openBreathing(tester);

      await tester.tap(find.text('Triangle breathing'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'Renamed triangle',
      );
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Renamed triangle'), findsWidgets);

      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('Renamed triangle'), findsNothing);
    });

    testWidgets('runs an exercise to completion', (tester) async {
      await openBreathing(tester, seed: Seed.quickBreath);

      await tester.tap(find.text('IT quick breath'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Exercise'));
      await tester.pumpAndSettle();

      expect(find.text('Ready to begin?'), findsOneWidget);
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Inhale'), findsOneWidget);

      await pumpUntil(
        tester,
        find.text('Ready to begin?'),
        timeout: const Duration(seconds: 15),
      );

      // No Timer should outlive the widget tree.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('breathing settings toggle and persist', (tester) async {
      await openBreathing(tester);

      await tester.tap(find.byTooltip('Breathing settings'));
      await tester.pumpAndSettle();

      expect(find.text('Currently: 1, 2, 3, 4'), findsOneWidget);
      await tester.tap(findAdaptiveSwitch().first);
      await tester.pumpAndSettle();
      expect(find.text('Currently: 4, 3, 2, 1'), findsOneWidget);

      await tester.tap(findAdaptiveSwitch().at(1)); // sounds
      await tester.pumpAndSettle();
      await tester.tap(findAdaptiveSwitch().at(2)); // vibrate
      await tester.pumpAndSettle();
    });
  });
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/breathing_test.dart -d <device-id>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => breathingTests();
