import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void welcomeTests() {
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

      // The changelog dialog follows immediately after the intro.
      await pumpUntil(tester, find.text('Great!'));
      await tester.tap(find.text('Great!'));
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

  group('Changelog dialog', () {
    testWidgets(
      'a fresh install sees the changelog after the intro and records the '
      'current version',
      (tester) async {
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

        // Dismissing the intro's last dialog kicks off the changelog dialog
        // in the same post-frame callback, so wait for it rather than
        // assuming pumpAndSettle already caught it.
        await pumpUntil(tester, find.text('Great!'));

        final info = await PackageInfo.fromPlatform();
        expect(find.text('New v${info.version} update!'), findsOneWidget);

        await tester.tap(find.text('Great!'));
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('lastSeenChangelogVersion'), info.version);
      },
    );

    testWidgets(
      'a returning user who has never seen a changelog sees the dialog',
      (tester) async {
        // Simulates a user who upgraded from a build predating this
        // feature: returningUser is set, but lastSeenChangelogVersion was
        // never recorded.
        await launchApp(tester, prefs: {'lastSeenChangelogVersion': null});

        final info = await PackageInfo.fromPlatform();
        await pumpUntil(tester, find.text('New v${info.version} update!'));
        expect(find.text('New v${info.version} update!'), findsOneWidget);
      },
    );

    testWidgets(
      'a returning user on an older changelog version sees the dialog',
      (tester) async {
        await launchApp(
          tester,
          prefs: {'lastSeenChangelogVersion': '0.0.1-older-than-anything'},
        );

        final info = await PackageInfo.fromPlatform();
        await pumpUntil(tester, find.text('New v${info.version} update!'));
        expect(find.text('New v${info.version} update!'), findsOneWidget);
      },
    );

    testWidgets(
      'a returning user already on the current changelog version sees no '
      'dialog',
      (tester) async {
        final info = await PackageInfo.fromPlatform();
        await launchApp(
          tester,
          prefs: {'lastSeenChangelogVersion': info.version},
        );

        expect(find.textContaining('update!'), findsNothing);
      },
    );
  });
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/welcome_test.dart -d <device-id>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => welcomeTests();
