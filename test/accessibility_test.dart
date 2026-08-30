import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolery/accessibility/color_picker_dialog.dart';
import 'package:toolery/accessibility/contrast.dart';
import 'package:toolery/forms/affirmation/main.dart';
import 'package:toolery/forms/breathing/main.dart';
import 'package:toolery/forms/tag/main.dart';
import 'package:toolery/forms/task/main.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/settings.dart';
import 'package:toolery/theme/app_theme.dart';

import 'helpers/finders.dart';
import 'helpers/mock_repositories.dart';

/// Theme carrying [platform], so `.adaptive` widgets and `isCupertino` pick
/// the right rendering without a leaking global override.
ThemeData _themeFor(TargetPlatform platform) => buildAppTheme(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(SettingsNotifier.defaultCustomThemeColor),
  ),
  platform: platform,
);

Widget _buildTestApp(
  Widget child, {
  TargetPlatform platform = TargetPlatform.android,
}) {
  final settings = SettingsNotifier()
    ..returningUser = true
    ..materialTheme = true;
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
    child: MaterialApp(theme: _themeFor(platform), home: child),
  );
}

Widget _buildSettingsApp({
  required bool materialTheme,
  TargetPlatform platform = TargetPlatform.android,
}) {
  final settings = SettingsNotifier()
    ..returningUser = true
    ..materialTheme = materialTheme;
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

void main() {
  group('Accessibility', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    const MethodChannel prefsChannel = MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );

    setUp(() {
      // SharedPreferences caches a static instance, so without this a test
      // that toggles a setting leaks that value into every later test.
      SharedPreferences.setMockInitialValues({});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(prefsChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'getAll') {
              return <String, Object>{};
            }
            return true;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(prefsChannel, null);
    });

    testWidgets('task page exposes create action tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const TaskPage()));
      await tester.pump();
      expect(find.byTooltip('Create task'), findsOneWidget);
    });

    testWidgets('breathing page exposes settings and create action tooltips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const BreathingPage()));
      await tester.pump();
      expect(find.byTooltip('Breathing settings'), findsOneWidget);
      expect(find.byTooltip('Create breathing exercise'), findsOneWidget);
    });

    testWidgets('affirmation page exposes create action tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const AffirmationPage()));
      await tester.pump();
      expect(find.byTooltip('Create affirmation list'), findsOneWidget);
    });

    testWidgets('configure tags page exposes create action tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const TagPage()));
      await tester.pump();
      expect(find.byTooltip('Create tag'), findsOneWidget);
    });

    testWidgets('settings color picker exposes tooltip labels for colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSettingsApp(materialTheme: true));
      await tester.pump();

      final themeColorTile = find.widgetWithText(
        SwitchListTile,
        'Use System Theme Color?',
      );
      await tester.tap(
        find.descendant(of: themeColorTile, matching: findAdaptiveSwitch()),
      );
      await tester.pump();
      expect(find.text('Set Custom Theme Color'), findsOneWidget);
      await tester.tap(find.text('Set Custom Theme Color'));
      await tester.pumpAndSettle();

      expect(
        find.byTooltip('Select color ${colorHexLabel(Colors.red)}'),
        findsOneWidget,
      );
    });

    // The tooltip is what makes the FAB -> nav-bar swap safe: it travels with
    // the action, so the same finder works on both platforms.
    const pagesWithPrimaryAction = <String, (Widget, String)>{
      'task': (TaskPage(), 'Create task'),
      'breathing': (BreathingPage(), 'Create breathing exercise'),
      'affirmation': (AffirmationPage(), 'Create affirmation list'),
      'tag': (TagPage(), 'Create tag'),
    };

    for (final entry in pagesWithPrimaryAction.entries) {
      final (page, tooltip) = entry.value;

      testWidgets('${entry.key} page keeps its FAB on Android', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_buildTestApp(page));
        await tester.pump();
        expect(find.byTooltip(tooltip), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('${entry.key} page moves its action to the nav bar on iOS', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _buildTestApp(page, platform: TargetPlatform.iOS),
        );
        await tester.pump();
        expect(find.byTooltip(tooltip), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      });
    }

    testWidgets('settings switches stay findable and operable on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildSettingsApp(materialTheme: true, platform: TargetPlatform.iOS),
      );
      await tester.pump();

      // `Switch.adaptive` restyles the Material switch through a theme
      // adaptation rather than substituting a CupertinoSwitch, so the same
      // finder works on both platforms — that is what keeps this cheap.
      final accentTile = find.widgetWithText(
        SwitchListTile,
        'Use iOS accent colour?',
      );
      expect(accentTile, findsOneWidget);

      await tester.tap(
        find.descendant(of: accentTile, matching: findAdaptiveSwitch()),
      );
      await tester.pump();
      expect(find.text('Set Custom Theme Color'), findsOneWidget);
    });

    test('contrast helper chooses highest-contrast text color', () {
      expect(highContrastTextColor(Colors.black), equals(Colors.white));
      expect(highContrastTextColor(Colors.white), equals(Colors.black));
      expect(
        highContrastTextColor(const Color(0xFFFF0000)),
        equals(Colors.black),
      );
      expect(
        highContrastTextColor(const Color(0xFF808080)),
        equals(Colors.black),
      );
      expect(
        highContrastTextColor(const Color(0xFF0000AA)),
        equals(Colors.white),
      );
    });
  });
}
