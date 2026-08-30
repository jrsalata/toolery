import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void taskTests() {
  registerAppHarnessTearDown();

  Future<void> openTasks(WidgetTester tester) async {
    await launchApp(tester);
    await tester.tap(findTab('Tasks'));
    await tester.pumpAndSettle();
  }

  group('Task CRUD', () {
    testWidgets('creates a task with all three fields', (tester) async {
      await openTasks(tester);

      await tester.tap(find.byTooltip('Create task'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'IT new task');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'A short description',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'Do the thing');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('IT new task'), findsOneWidget);
    });

    testWidgets('opens a task and views its detail', (tester) async {
      await openTasks(tester);

      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();

      expect(find.text('Hydrate'), findsOneWidget);
      expect(
        find.text('Slowly drink a glass of water to fuel your body.'),
        findsOneWidget,
      );
    });

    testWidgets('edits a task and the list reflects it', (tester) async {
      await openTasks(tester);

      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Hydrate well');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Back at the (reloaded) detail page.
      expect(find.text('Hydrate well'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Hydrate well'), findsOneWidget);
    });

    testWidgets('deletes a task from the detail overflow menu', (tester) async {
      await openTasks(tester);

      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last); // confirm dialog
      await tester.pumpAndSettle();

      expect(find.text('Drink water'), findsNothing);
    });

    testWidgets('empty name fails validation', (tester) async {
      await openTasks(tester);

      await tester.tap(find.byTooltip('Create task'));
      await tester.pumpAndSettle();

      // Leave the name blank; fill the other two required fields.
      await tester.enterText(find.byType(TextFormField).at(1), 'Description');
      await tester.enterText(find.byType(TextFormField).at(2), 'Activity');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to validate!'), findsOneWidget);
    });

    testWidgets('unsaved changes guard blocks a discarded edit', (
      tester,
    ) async {
      await openTasks(tester);

      await tester.tap(find.byTooltip('Create task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Half-written');
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Back at the task list, nothing created.
      expect(find.text('Half-written'), findsNothing);
    });
  });
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/task_test.dart -d <device-id>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => taskTests();
