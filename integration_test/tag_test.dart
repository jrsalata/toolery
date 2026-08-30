import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void tagTests() {
  registerAppHarnessTearDown();

  Future<void> openTags(WidgetTester tester) async {
    await launchApp(tester);
    await tester.tap(findTab('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configure Tags'));
    await tester.pumpAndSettle();
  }

  group('Tags', () {
    testWidgets('lists the seeded tags', (tester) async {
      await openTags(tester);

      expect(find.text('mindfulness'), findsOneWidget);
      expect(find.text('breathing'), findsOneWidget);
      expect(find.text('stress'), findsOneWidget);
      expect(find.text('anxiety'), findsOneWidget);
      expect(find.text('self-care'), findsOneWidget);
    });

    testWidgets('creates a tag with a picked colour', (tester) async {
      await openTags(tester);

      await tester.tap(find.byTooltip('Create tag'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'IT tag');
      await tester.tap(find.text('Set Tag Color'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Select color #4CAF50')); // Colors.green
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done!'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('IT tag'), findsOneWidget);
    });

    testWidgets('renames a tag', (tester) async {
      await openTags(tester);

      await tester.tap(find.text('mindfulness'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'mindfulness-renamed');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('mindfulness-renamed'), findsOneWidget);
    });

    testWidgets('deletes a tag', (tester) async {
      await openTags(tester);

      await tester.tap(find.text('anxiety'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('anxiety'), findsNothing);
    });

    testWidgets('assigns a tag to a task', (tester) async {
      await launchApp(tester);
      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'mindfulness'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('mindfulness'), findsOneWidget);
    });

    testWidgets('assigns multiple tags to a task without dropping earlier '
        'selections', (tester) async {
      await launchApp(tester);
      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'mindfulness'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'stress'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('mindfulness'), findsOneWidget);
      expect(find.text('stress'), findsOneWidget);
    });

    testWidgets('filters the task list by tag', (tester) async {
      await launchApp(tester);
      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();

      // Only "Take a walk" carries the seeded "stress" tag (tasktag 3->3).
      await tester.tap(find.widgetWithText(FilterChip, 'stress'));
      await tester.pumpAndSettle();

      expect(find.text('Take a walk'), findsOneWidget);
      expect(find.text('Drink water'), findsNothing);

      // Switch to a tag no task carries.
      await tester.tap(find.widgetWithText(FilterChip, 'stress'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'breathing'));
      await tester.pumpAndSettle();

      expect(find.text('No tasks match the selected filters'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'breathing'));
      await tester.pumpAndSettle();

      expect(find.text('Take a walk'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
    });
  });
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/tag_test.dart -d <device-id>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => tagTests();
