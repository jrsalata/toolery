import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void affirmationTests() {
  registerAppHarnessTearDown();

  Future<void> openAffirmations(WidgetTester tester) async {
    await launchApp(tester);
    await tester.tap(find.text('Affirmations'));
    await tester.pumpAndSettle();
  }

  group('Affirmation lists', () {
    testWidgets('lists render with an item count', (tester) async {
      await openAffirmations(tester);

      expect(find.text('Morning Affirmations'), findsOneWidget);
      expect(find.text('3 affirmations'), findsOneWidget);
      expect(find.text('Peace Reminders'), findsOneWidget);
      expect(find.text('4 affirmations'), findsOneWidget);
    });

    testWidgets('opens a list and sees its items', (tester) async {
      await openAffirmations(tester);

      await tester.tap(find.text('Morning Affirmations'));
      await tester.pumpAndSettle();

      expect(find.text('I am enough exactly as I am'), findsOneWidget);
    });

    testWidgets('adds an item', (tester) async {
      await openAffirmations(tester);

      await tester.tap(find.text('Morning Affirmations'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add affirmation'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'IT new affirmation');

      await tester.tap(
        find.ancestor(
          of: find.text('Add'),
          matching: find.byType(FilledButton),
        ),
      );
      // The dialog owns the only text field on this page; its removal is the
      // signal that the add completed and the dialog popped.
      await pumpUntilSaved(tester, editor: find.byType(TextFormField));

      expect(find.text('IT new affirmation'), findsOneWidget);
    });

    testWidgets('edits an item', (tester) async {
      await openAffirmations(tester);

      await tester.tap(find.text('Peace Reminders'));
      await tester.pumpAndSettle();

      final Finder row = find.widgetWithText(ListTile, 'I can do hard things');
      await tester.tap(
        find.descendant(of: row, matching: find.byTooltip('Edit')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'I can do hard things, always',
      );
      await tester.tap(find.text('Save'));
      await pumpUntilSaved(tester, editor: find.byType(TextFormField));

      expect(find.text('I can do hard things, always'), findsOneWidget);
    });

    testWidgets('deletes an item', (tester) async {
      await openAffirmations(tester);

      await tester.tap(find.text('Peace Reminders'));
      await tester.pumpAndSettle();

      final Finder row = find.widgetWithText(ListTile, 'My feelings are valid');
      await tester.tap(
        find.descendant(of: row, matching: find.byTooltip('Delete')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await pumpUntilGone(tester, find.text('My feelings are valid'));

      expect(find.text('My feelings are valid'), findsNothing);
    });

    testWidgets('shuffle opens a dialog titled with the list name', (
      tester,
    ) async {
      await openAffirmations(tester);

      final Finder row = find.widgetWithText(ListTile, 'Morning Affirmations');
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byTooltip('Random affirmation'),
        ),
      );
      await tester.pumpAndSettle();

      // The dialog title is deterministic; its body text is randomly picked
      // from the list, so only the title is asserted. The title also appears
      // on the list tile behind the dialog, so wait on the dialog's own
      // Close action rather than the title to know it is actually up.
      await pumpUntil(tester, find.text('Close'));
      expect(find.text('Morning Affirmations'), findsWidgets);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('creates then deletes a whole list', (tester) async {
      await openAffirmations(tester);

      await tester.tap(find.byTooltip('Create affirmation list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'IT temp list');
      await tester.tap(find.text('Add List'));
      await pumpUntilSaved(tester, editor: find.byType(TextFormField));

      expect(find.text('IT temp list'), findsOneWidget);

      final Finder row = find.widgetWithText(ListTile, 'IT temp list');
      await tester.tap(
        find.descendant(of: row, matching: find.byTooltip('Delete list')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await pumpUntilGone(tester, find.text('IT temp list'));

      expect(find.text('IT temp list'), findsNothing);
    });
  });
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/affirmation_test.dart -d <device-id>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => affirmationTests();
