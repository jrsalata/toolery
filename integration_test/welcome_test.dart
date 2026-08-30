import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';

void main() {
  registerAppHarnessTearDown();

  group('Welcome dialogs', () {
    testWidgets('first launch walks the five intro dialogs', (tester) async {
      await launchApp(tester, returningUser: false);

      expect(find.text('Welcome'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        find.text('Tasks'),
        findsAtLeastNWidgets(1),
      ); // same descriptor is used 3 times
      await tester.tap(find.text('Neat!'));
      await tester.pumpAndSettle();

      expect(find.text('Breathing Exercises'), findsAtLeastNWidgets(1));
      await tester.tap(find.text('Cool!'));
      await tester.pumpAndSettle();

      expect(find.text('Tags'), findsAtLeastNWidgets(1));
      await tester.tap(find.text('Shiny!'));
      await tester.pumpAndSettle();

      expect(find.text('One Last Reminder'), findsOneWidget);
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      // Back at the Welcome page, dialogs gone, the four cards visible.
      expect(find.text('Journal'), findsAtLeastNWidgets(2));
      expect(find.text('Tasks'), findsAtLeastNWidgets(2));
      expect(find.text('Breathing Exercises'), findsAtLeastNWidgets(1));
      expect(find.text('Affirmations'), findsAtLeastNWidgets(1));
    });

    testWidgets('the intro dialogs cannot be dismissed by tapping outside', (
      tester,
    ) async {
      await launchApp(tester, returningUser: false);
      expect(find.text('Welcome'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('finishing the intro marks the user as returning', (
      tester,
    ) async {
      await launchApp(tester, returningUser: false);

      for (final String label in <String>[
        'OK',
        'Neat!',
        'Cool!',
        'Shiny!',
        'Understood',
      ]) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('returningUser'), isTrue);
    });

    testWidgets('a returning user sees no intro dialogs', (tester) async {
      await launchApp(tester); // returningUser: true by default
      expect(find.text('Welcome'), findsNothing);
    });
  });
}
