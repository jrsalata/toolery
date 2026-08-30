import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void main() {
  registerAppHarnessTearDown();

  group('Tab navigation', () {
    testWidgets('every tab opens its page', (tester) async {
      await launchApp(tester);

      // Menu (index 0) is already showing.
      expect(find.text('Welcome to Toolery!'), findsOneWidget);

      await tester.tap(findTab('Journal'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Create journal entry'), findsOneWidget);

      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Create task'), findsOneWidget);

      await tester.tap(findTab('Breathing'));
      await tester.pumpAndSettle();
      expect(find.text('Breathing Exercises'), findsOneWidget);

      await tester.tap(findTab('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);

      await tester.tap(findTab('Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Toolery!'), findsOneWidget);
    });

    testWidgets('affirmations open from the menu card, not a tab', (
      tester,
    ) async {
      await launchApp(tester);

      await tester.tap(find.text('Affirmations'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Create affirmation list'), findsOneWidget);
    });

    testWidgets('tags open from settings, not a tab', (tester) async {
      await launchApp(tester);

      await tester.tap(findTab('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Configure Tags'));
      await tester.pumpAndSettle();

      expect(find.text('Configure Tags'), findsOneWidget);
      // The five demo tags from the onCreate seed.
      expect(find.text('mindfulness'), findsOneWidget);
      expect(find.text('self-care'), findsOneWidget);
    });

    testWidgets('back returns from tags to settings', (tester) async {
      await launchApp(tester);

      await tester.tap(findTab('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Configure Tags'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
    });
  });
}
