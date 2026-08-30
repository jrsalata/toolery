import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void settingsTests() {
  registerAppHarnessTearDown();

  Future<void> openSettings(WidgetTester tester) async {
    await launchApp(tester);
    await tester.tap(findTab('Settings'));
    await tester.pumpAndSettle();
  }

  group('Settings', () {
    testWidgets('switches to dark mode', (tester) async {
      await openSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'dark');
    });

    testWidgets('system and light are also selectable', (tester) async {
      await openSettings(tester);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.system,
      );
    });

    testWidgets('turning off the system theme reveals the custom colour tile', (
      tester,
    ) async {
      await openSettings(tester);

      expect(find.text('Set Custom Theme Color'), findsNothing);

      await tester.tap(findAdaptiveSwitch().first);
      await tester.pumpAndSettle();
      expect(find.text('Set Custom Theme Color'), findsOneWidget);

      await tester.tap(findAdaptiveSwitch().first);
      await tester.pumpAndSettle();
      expect(find.text('Set Custom Theme Color'), findsNothing);
    });

    testWidgets('picks a custom theme colour', (tester) async {
      await openSettings(tester);

      await tester.tap(findAdaptiveSwitch().first); // reveal the custom tile
      await tester.pumpAndSettle();
      await tester.tap(find.text('Set Custom Theme Color'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Select color #4CAF50')); // Colors.green
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done!'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('customThemeColor'), Colors.green.toARGB32());
    });

    testWidgets('renders every tab at 200% text scale without overflow', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await launchApp(tester);
      expect(tester.takeException(), isNull);

      for (final String label in <String>[
        'Journal',
        'Tasks',
        'Breathing',
        'Settings',
        'Menu',
      ]) {
        await tester.tap(findTab(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tester.tap(findTab('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Configure Tags'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(findTab('Breathing'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Breathing settings'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the about dialog', (tester) async {
      await openSettings(tester);

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('Created by John Salata'), findsOneWidget);

      // Dismiss (Material 'OK'/'Close' or Cupertino 'Close' action).
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
    });
  });
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/settings_test.dart -d <device-id>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => settingsTests();
