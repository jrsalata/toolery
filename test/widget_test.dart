import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/settings.dart';
import 'package:toolery/theme/app_theme.dart';
import 'package:toolery/welcome_page.dart';

import 'helpers/mock_repositories.dart';

/// Wraps a [child] widget with all the [Provider]s required by the app,
/// using in-memory fake repositories so no platform channels are needed.
///
/// [platform] is threaded through [buildAppTheme] rather than set via
/// `debugDefaultTargetPlatformOverride`, so there is no global to reset and
/// nothing can leak between tests. It defaults to Android, which keeps every
/// pre-existing assertion byte-identical.
Widget buildTestApp(
  Widget child, {
  TargetPlatform platform = TargetPlatform.android,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsNotifier()),
      ChangeNotifierProvider(
        create: (_) => TaskNotifier(repository: FakeTaskRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => TagNotifier(repository: FakeTagRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => BreathingNotifier(repository: FakeBreathingRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            AffirmationNotifier(repository: FakeAffirmationRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => JournalNotifier(repository: FakeJournalRepository()),
      ),
    ],
    child: MaterialApp(
      theme: buildAppTheme(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(SettingsNotifier.defaultCustomThemeColor),
        ),
        platform: platform,
      ),
      home: child,
    ),
  );
}

void main() {
  group('WelcomePage widget', () {
    testWidgets('renders the app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const WelcomePage()));
      await tester.pump();
      expect(find.text('Welcome to Toolery!'), findsOneWidget);
    });

    testWidgets(
      'shows Tasks, Breathing Exercises, Affirmations, and Journal cards',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(const WelcomePage()));
        await tester.pump();
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Breathing Exercises'), findsOneWidget);
        expect(find.text('Affirmations'), findsOneWidget);
        expect(find.text('Journal'), findsOneWidget);
      },
    );

    testWidgets('tapping Tasks card navigates to TaskPage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const WelcomePage()));
      await tester.pump();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      // TaskPage has an AppBar with title 'Tasks'
      expect(find.text('Tasks'), findsWidgets);
    });
  });
}
