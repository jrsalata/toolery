import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void main() {
  registerAppHarnessTearDown();

  Future<void> openJournal(WidgetTester tester) async {
    await launchApp(tester);
    await tester.tap(findTab('Journal'));
    await tester.pumpAndSettle();
  }

  group('Journal CRUD', () {
    testWidgets('views the saved body read-only', (tester) async {
      await openJournal(tester);

      await tester.tap(find.byTooltip('Create journal entry'));
      await tester.pumpAndSettle();
      await tester.tap(quillTitle());
      await tester.enterText(quillTitle(), 'IT view entry');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('IT view entry'));
      await tester.pumpAndSettle();

      expect(find.text('IT view entry'), findsOneWidget);
      expect(find.byTooltip('Save'), findsNothing);
    });

    testWidgets('edits title and body', (tester) async {
      await openJournal(tester);

      await tester.tap(find.byTooltip('Create journal entry'));
      await tester.pumpAndSettle();
      await tester.tap(quillTitle());
      await tester.enterText(quillTitle(), 'IT edit entry');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('IT edit entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.tap(quillTitle());
      await tester.enterText(quillTitle(), 'IT edited entry');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // JournalView reloads after Update pops.
      expect(find.text('IT edited entry'), findsOneWidget);
    });

    testWidgets('guards unsaved quill changes on a body-only edit', (
      tester,
    ) async {
      await openJournal(tester);

      await tester.tap(find.byTooltip('Create journal entry'));
      await tester.pumpAndSettle();
      await tester.tap(quillTitle());
      await tester.enterText(quillTitle(), 'IT guard entry');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('IT guard entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      await tester.tap(quillBody());
      await tester.enterText(quillBody(), 'an unsaved change');
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
    });

    testWidgets('deletes an entry and lands on the list', (tester) async {
      await openJournal(tester);

      await tester.tap(find.byTooltip('Create journal entry'));
      await tester.pumpAndSettle();
      await tester.tap(quillTitle());
      await tester.enterText(quillTitle(), 'IT delete entry');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('IT delete entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Deleting from JournalView pops straight to the list.
      expect(find.text('IT delete entry'), findsNothing);
      expect(find.byTooltip('Create journal entry'), findsOneWidget);
    });
  });
}
