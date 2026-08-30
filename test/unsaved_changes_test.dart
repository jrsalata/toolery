import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/journal/create.dart';
import 'package:toolery/forms/journal/update.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

import 'helpers/mock_repositories.dart';

/// Reads `canPop` off the [PopScope] that [UnsavedChangesGuard] renders.
///
/// Scoped to a descendant of the guard so unrelated framework `PopScope`s
/// (e.g. inside a route) can't be picked up by mistake.
bool canPopOf(WidgetTester tester) {
  final dynamic popScope = tester.widget(
    find
        .descendant(
          of: find.byType(UnsavedChangesGuard),
          matching: find.byWidgetPredicate((w) => w is PopScope),
        )
        .first,
  );
  return popScope.canPop as bool;
}

Widget _wrapJournal(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => JournalNotifier(repository: FakeJournalRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => TagNotifier(repository: FakeTagRepository()),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  group('UnsavedChangesGuard', () {
    testWidgets('a clean guard allows the pop', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: UnsavedChangesGuard(
            isDirty: () => controller.text.isNotEmpty,
            watch: [controller],
            child: Scaffold(body: TextField(controller: controller)),
          ),
        ),
      );

      expect(canPopOf(tester), isTrue);
    });

    testWidgets('typing into a watched controller blocks the pop', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: UnsavedChangesGuard(
            isDirty: () => controller.text.isNotEmpty,
            watch: [controller],
            child: Scaffold(body: TextField(controller: controller)),
          ),
        ),
      );
      expect(canPopOf(tester), isTrue);

      // No parent setState here — the guard must react to the controller
      // notifying on its own.
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();

      expect(canPopOf(tester), isFalse);
    });

    testWidgets('clearing the change restores the pop', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: UnsavedChangesGuard(
            isDirty: () => controller.text.isNotEmpty,
            watch: [controller],
            child: Scaffold(body: TextField(controller: controller)),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      expect(canPopOf(tester), isFalse);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(canPopOf(tester), isTrue);
    });
  });

  group('Journal editors', () {
    const entry = Journal(
      id: 1,
      title: 'Existing',
      dateWritten: '2026-01-01T00:00:00.000',
      content: '[{"insert":"already written\\n"}]',
    );

    testWidgets('a freshly opened new entry is clean', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapJournal(const CreateJournal()));
      await tester.pumpAndSettle();

      expect(canPopOf(tester), isTrue);
    });

    testWidgets('editing the body of a new entry marks it dirty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapJournal(const CreateJournal()));
      await tester.pumpAndSettle();
      expect(canPopOf(tester), isTrue);

      // The Quill body is the last EditableText on the page; the title
      // field is the first.
      await tester.enterText(find.byType(EditableText).last, 'hello');
      await tester.pumpAndSettle();

      expect(canPopOf(tester), isFalse);
    });

    testWidgets('an unmodified existing entry is clean', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapJournal(const UpdateJournal(entry: entry)));
      await tester.pumpAndSettle();

      expect(canPopOf(tester), isTrue);
    });

    testWidgets('editing the title of an existing entry marks it dirty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapJournal(const UpdateJournal(entry: entry)));
      await tester.pumpAndSettle();
      expect(canPopOf(tester), isTrue);

      await tester.enterText(find.byType(EditableText).first, 'Renamed');
      await tester.pumpAndSettle();

      expect(canPopOf(tester), isFalse);
    });
  });
}
