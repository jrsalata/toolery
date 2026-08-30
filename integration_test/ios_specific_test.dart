import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

/// Cupertino-only chrome that the shared cross-platform files deliberately
/// never assert on (see the tooltip/[findTab] convention in
/// `integration_test/helpers/finders.dart`).
///
/// The group below is skipped outright on Android via `skip: !Platform.isIOS`
/// rather than filtered per test.
void iosSpecificTests() {
  registerAppHarnessTearDown();

  group('iOS chrome', () {
    testWidgets('the primary action is a nav-bar button, not a FAB', (
      tester,
    ) async {
      await launchApp(tester);
      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byTooltip('Create task'), findsOneWidget);
    });

    testWidgets('the tab bar is a CupertinoTabBar', (tester) async {
      await launchApp(tester);

      expect(find.byType(CupertinoTabBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('appearance uses a sliding segmented control', (tester) async {
      await launchApp(tester);
      await tester.tap(findTab('Settings'));
      await tester.pumpAndSettle();

      expect(
        find.byType(CupertinoSlidingSegmentedControl<ThemeMode>),
        findsOneWidget,
      );

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
    });

    testWidgets('the overflow menu is a Cupertino action sheet', (
      tester,
    ) async {
      await launchApp(tester);
      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('back-swipe pops a clean detail page but not a dirty editor', (
      tester,
    ) async {
      await launchApp(tester);
      await tester.tap(findTab('Tasks'));
      await tester.pumpAndSettle();

      // Clean page: the gesture completes.
      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      final Size size = tester.getSize(find.byType(Scaffold).first);
      await tester.dragFrom(Offset(0, size.height / 2), const Offset(320, 0));
      await tester.pumpAndSettle();
      expect(find.text('Drink water'), findsOneWidget); // back at the list

      // Dirty editor: UnsavedChangesGuard disables the gesture entirely.
      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Dirty edit');
      await tester.pumpAndSettle();

      await tester.dragFrom(Offset(0, size.height / 2), const Offset(320, 0));
      await tester.pumpAndSettle();
      // Still on the editor: the field we just typed into is present.
      expect(find.text('Dirty edit'), findsOneWidget);
    });
  }, skip: !Platform.isIOS);
}

/// Lets this file run standalone during development, e.g.
/// `flutter test integration_test/ios_specific_test.dart -d <UDID>`.
/// The full suite runs these grouped in `all_test.dart` instead.
void main() => iosSpecificTests();
