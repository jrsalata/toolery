import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
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

import 'helpers/mock_repositories.dart';

Widget _buildTestApp(Widget child) {
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
    child: MaterialApp(home: child),
  );
}

Widget _buildSettingsApp({required bool materialTheme}) {
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
        create: (_) => AffirmationNotifier(repository: FakeAffirmationRepository()),
      ),
    ],
    child: MaterialApp(
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

    const MethodChannel prefsChannel =
        MethodChannel('plugins.flutter.io/shared_preferences');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(prefsChannel, (MethodCall methodCall) async {
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

    testWidgets('task page exposes create action tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const TaskPage()));
      await tester.pump();
      expect(find.byTooltip('Create task'), findsOneWidget);
    });

    testWidgets('breathing page exposes settings and create action tooltips',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const BreathingPage()));
      await tester.pump();
      expect(find.byTooltip('Breathing settings'), findsOneWidget);
      expect(find.byTooltip('Create breathing exercise'), findsOneWidget);
    });

    testWidgets('affirmation page exposes create action tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const AffirmationPage()));
      await tester.pump();
      expect(find.byTooltip('Create affirmation list'), findsOneWidget);
    });

    testWidgets('configure tags page exposes create action tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const TagPage()));
      await tester.pump();
      expect(find.byTooltip('Create tag'), findsOneWidget);
    });

    testWidgets('settings switches include semantic labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildSettingsApp(materialTheme: true));
      await tester.pump();

      final semantics = SemanticsTester(tester);
      expect(semantics, includesNodeWith(label: 'Enable dark mode'));
      expect(semantics, includesNodeWith(label: 'Use system theme color'));
      semantics.dispose();
    });

    testWidgets('settings color picker exposes tooltip labels for colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildSettingsApp(materialTheme: true));
      await tester.pump();

      await tester.tap(find.text('Use System Theme Color?'));
      await tester.pump();
      await tester.tap(find.text('Set Custom Theme Color'));
      await tester.pumpAndSettle();

      expect(
        find.byTooltip('Select color ${colorHexLabel(Colors.red)}'),
        findsOneWidget,
      );
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
