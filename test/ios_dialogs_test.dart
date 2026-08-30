import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolery/accessibility/color_picker_dialog.dart';
import 'package:toolery/forms/affirmation/detail.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/settings.dart';
import 'package:toolery/theme/app_theme.dart';

import 'helpers/mock_repositories.dart';

ThemeData _themeFor(TargetPlatform platform) => buildAppTheme(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(SettingsNotifier.defaultCustomThemeColor),
  ),
  platform: platform,
);

Widget _pickerHarness(TargetPlatform platform) {
  return MaterialApp(
    theme: _themeFor(platform),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => showAccessibleColorPickerDialog(
              context: context,
              pickerColor: Colors.red,
              onColorChanged: (_) {},
            ),
            child: const Text('open picker'),
          ),
        ),
      ),
    ),
  );
}

Widget _settingsApp(TargetPlatform platform) {
  final settings = SettingsNotifier()..returningUser = true;
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsNotifier>.value(value: settings),
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
    ],
    child: MaterialApp(
      theme: _themeFor(platform),
      home: SettingsPage(
        packageInfo: PackageInfo(
          appName: 'Toolery',
          packageName: 'software.salata.toolery',
          version: '0.1.0',
          buildNumber: '1',
          buildSignature: '',
          installerStore: '',
        ),
      ),
    ),
  );
}

Widget _affirmationApp(TargetPlatform platform) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) =>
            AffirmationNotifier(repository: FakeAffirmationRepository()),
      ),
    ],
    child: MaterialApp(
      theme: _themeFor(platform),
      home: const AffirmationDetailPage(
        list: AffirmationList(id: 1, name: 'Reminders'),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final name = platform == TargetPlatform.iOS ? 'iOS' : 'Android';

    testWidgets('$name: the colour picker opens without a Material error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_pickerHarness(platform));
      await tester.tap(find.text('open picker'));
      await tester.pumpAndSettle();

      // A CupertinoAlertDialog is not a Material ancestor, so anything using
      // InkWell inside one throws.
      expect(tester.takeException(), isNull);
      expect(
        find.byTooltip('Select color ${colorHexLabel(Colors.red)}'),
        findsOneWidget,
      );
    });

    testWidgets('$name: the About dialog shows its credits', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_settingsApp(platform));
      await tester.pump();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // hitTestable, not just findsOneWidget: CupertinoAlertDialog clips its
      // content, so the credits can be laid out and still be invisible to the
      // user. Presence in the tree is not the property we care about.
      expect(find.text('Created by John Salata').hitTestable(), findsOneWidget);
      expect(
        find.text('App icon created by Morgan Roberts').hitTestable(),
        findsOneWidget,
      );
    });

    testWidgets('$name: the affirmation editor dialog opens cleanly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_affirmationApp(platform));
      await tester.pump();

      await tester.tap(find.byTooltip('Add affirmation'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Add Affirmation'), findsOneWidget);
      expect(find.byType(TextFormField).hitTestable(), findsOneWidget);
    });
  }
}
