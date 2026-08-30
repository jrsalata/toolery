// System imports
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/main.dart';
import 'package:toolery/forms/journal/main.dart';
import 'package:toolery/forms/task/main.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/repositories/affirmation.dart';
import 'package:toolery/repositories/breathing.dart';
import 'package:toolery/repositories/journal.dart';
import 'package:toolery/repositories/tag.dart';
import 'package:toolery/repositories/task.dart';
// Page imports
import 'package:toolery/settings.dart';
import 'package:toolery/theme/app_theme.dart';
import 'package:toolery/welcome_page.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';

void main() {
  runApp(buildToolery());
}

/// The app's widget tree, with its repositories injectable.
///
/// [main] and the integration-test harness both go through here, so tests
/// drive the same provider graph and the same [Main]/[MaterialApp] the user
/// gets rather than a hand-assembled copy. Every repository defaults to its
/// SQLite implementation, which keeps [main] a one-liner and lets a test
/// override only what it cares about.
Widget buildToolery({
  TaskRepository? taskRepository,
  TagRepository? tagRepository,
  BreathingRepository? breathingRepository,
  AffirmationRepository? affirmationRepository,
  JournalRepository? journalRepository,
}) {
  final TaskRepository taskRepo = taskRepository ?? SqliteTaskRepository();
  final TagRepository tagRepo = tagRepository ?? SqliteTagRepository();
  final BreathingRepository breathingRepo =
      breathingRepository ?? SqliteBreathingRepository();
  final AffirmationRepository affirmationRepo =
      affirmationRepository ?? SqliteAffirmationRepository();
  final JournalRepository journalRepo =
      journalRepository ?? SqliteJournalRepository();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsNotifier()),
      ChangeNotifierProvider(create: (_) => TaskNotifier(repository: taskRepo)),
      ChangeNotifierProvider(create: (_) => TagNotifier(repository: tagRepo)),
      ChangeNotifierProvider(
        create: (_) => BreathingNotifier(repository: breathingRepo),
      ),
      ChangeNotifierProvider(
        create: (_) => AffirmationNotifier(repository: affirmationRepo),
      ),
      ChangeNotifierProvider(
        create: (_) => JournalNotifier(repository: journalRepo),
      ),
    ],
    child: const Main(),
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return Consumer<SettingsNotifier>(
          builder: (context, settings, child) => MaterialApp(
            title: 'Toolery',
            theme: buildAppTheme(
              colorScheme: appColorScheme(
                useSystemAccent: settings.materialTheme,
                customThemeColor: settings.customTheme,
                dynamicScheme: lightDynamic,
                brightness: Brightness.light,
                platform: defaultTargetPlatform,
              ),
              platform: defaultTargetPlatform,
            ),
            darkTheme: buildAppTheme(
              colorScheme: appColorScheme(
                useSystemAccent: settings.materialTheme,
                customThemeColor: settings.customTheme,
                dynamicScheme: darkDynamic,
                brightness: Brightness.dark,
                platform: defaultTargetPlatform,
              ),
              platform: defaultTargetPlatform,
            ),
            themeMode: settings.themeMode,
            home: child,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
          ),
          child: const MainPage(),
        );
      },
    );
  }
}

// MainPage is essentially a Widget + NavigationBar
// This makes it easier and less repetitive to add the bar to needed pages
// It also controls navigation between widgets
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentDestination = 0;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTabShell(
      // NOTE: body and destinations must be in the same order to navigate
      body: [
        const WelcomePage(),
        const JournalPage(),
        const TaskPage(),
        const BreathingPage(),
        SettingsPage(packageInfo: _packageInfo),
      ][currentDestination],
      destinations: const [
        AdaptiveTabDestination(
          label: 'Menu',
          icon: Icons.home,
          cupertinoIcon: CupertinoIcons.house,
        ),
        AdaptiveTabDestination(
          label: 'Journal',
          icon: Icons.menu_book,
          cupertinoIcon: CupertinoIcons.book,
        ),
        AdaptiveTabDestination(
          label: 'Tasks',
          icon: Icons.task_alt_rounded,
          cupertinoIcon: CupertinoIcons.checkmark_circle,
        ),
        AdaptiveTabDestination(
          label: 'Breathing',
          icon: Icons.air,
          cupertinoIcon: CupertinoIcons.wind,
        ),
        AdaptiveTabDestination(
          label: 'Settings',
          icon: Icons.settings,
          cupertinoIcon: CupertinoIcons.settings,
        ),
      ],
      onDestinationSelected: (int index) {
        setState(() {
          currentDestination = index;
        });
      },
      selectedIndex: currentDestination,
    );
  }
}
