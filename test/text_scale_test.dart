import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolery/forms/affirmation/main.dart';
import 'package:toolery/forms/breathing/main.dart';
import 'package:toolery/forms/breathing/settings.dart';
import 'package:toolery/forms/journal/main.dart';
import 'package:toolery/forms/tag/main.dart';
import 'package:toolery/forms/task/main.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/settings.dart';
import 'package:toolery/theme/app_theme.dart';
import 'package:toolery/welcome_page.dart';

import 'helpers/mock_repositories.dart';

/// iOS users change system text size far more than Android users, and it is
/// the fastest way to break a layout. Rather than clamping text scaling
/// globally — which would be an accessibility regression — these tests pump
/// each screen at 200% and fail on any layout overflow.
Widget _scaledApp(
  Widget child, {
  required double textScale,
  required TargetPlatform platform,
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
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final screens = <String, Widget Function()>{
    'welcome': () => const WelcomePage(),
    'tasks': () => const TaskPage(),
    'breathing': () => const BreathingPage(),
    'affirmations': () => const AffirmationPage(),
    'tags': () => const TagPage(),
    'journal': () => const JournalPage(),
    'breathing settings': () => const BreathingSettingsPage(),
    'settings': () => SettingsPage(
      packageInfo: PackageInfo(
        appName: 'Toolery',
        packageName: 'software.salata.toolery',
        version: '0.1.0',
        buildNumber: '1',
        buildSignature: '',
        installerStore: '',
      ),
    ),
  };

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final platformName = platform == TargetPlatform.iOS ? 'iOS' : 'Android';

    group('$platformName at 200% text scale', () {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} lays out without overflow', (
          WidgetTester tester,
        ) async {
          // A phone-sized viewport: the tighter the width, the likelier a
          // scaled-up label is to overflow its row.
          tester.view.physicalSize = const Size(1170, 2532);
          tester.view.devicePixelRatio = 3.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            _scaledApp(entry.value(), textScale: 2.0, platform: platform),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
