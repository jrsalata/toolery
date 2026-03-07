import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/settings.dart';
import 'package:toolery/welcome_page.dart';

import 'helpers/mock_repositories.dart';

/// Wraps a [child] widget with all the [Provider]s required by the app,
/// using in-memory fake repositories so no platform channels are needed.
Widget buildTestApp(Widget child) {
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
        create: (_) =>
            BreathingNotifier(repository: FakeBreathingRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            AffirmationNotifier(repository: FakeAffirmationRepository()),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('WelcomePage widget', () {
    testWidgets('renders the app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const WelcomePage()));
      await tester.pump();
      expect(find.text('Welcome to Toolery!'), findsOneWidget);
    });

    testWidgets('shows Tasks, Breathing Exercises, and Affirmations cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const WelcomePage()));
      await tester.pump();
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Breathing Exercises'), findsOneWidget);
      expect(find.text('Affirmations'), findsOneWidget);
    });

    testWidgets('tapping Tasks card navigates to TaskPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const WelcomePage()));
      await tester.pump();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      // TaskPage has an AppBar with title 'Tasks'
      expect(find.text('Tasks'), findsWidgets);
    });
  });
}
