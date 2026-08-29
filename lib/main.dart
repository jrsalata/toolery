// System imports
import 'package:dynamic_color/dynamic_color.dart';
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
import 'package:toolery/welcome_page.dart';

void main() {
  TaskRepository taskRepo = SqliteTaskRepository();
  TagRepository tagRepo = SqliteTagRepository();
  BreathingRepository breathingRepo = SqliteBreathingRepository();
  AffirmationRepository affirmationRepo = SqliteAffirmationRepository();
  JournalRepository journalRepo = SqliteJournalRepository();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
        ChangeNotifierProvider(
          create: (_) => TaskNotifier(repository: taskRepo),
        ),
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
    ),
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
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: settings.materialTheme
                  ? (lightDynamic?.harmonized() ??
                        ColorScheme.fromSeed(
                          seedColor: Color(settings.customTheme),
                        ))
                  : ColorScheme.fromSeed(
                      seedColor: Color(settings.customTheme),
                    ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: settings.materialTheme
                  ? (darkDynamic?.harmonized() ??
                        ColorScheme.fromSeed(
                          seedColor: Color(settings.customTheme),
                          brightness: Brightness.dark,
                        ))
                  : ColorScheme.fromSeed(
                      seedColor: Color(settings.customTheme),
                      brightness: Brightness.dark,
                    ),
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
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
    return SafeArea(
      child: Scaffold(
        // NOTE: body and destinations must be in the same order to navigate
        body: [
          const WelcomePage(),
          const JournalPage(),
          const TaskPage(),
          const BreathingPage(),
          SettingsPage(packageInfo: _packageInfo),
        ][currentDestination],
        bottomNavigationBar: NavigationBar(
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home), label: 'Menu'),
            const NavigationDestination(
              icon: Icon(Icons.menu_book),
              label: 'Journal',
            ),
            const NavigationDestination(
              icon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
            const NavigationDestination(
              icon: Icon(Icons.air),
              label: 'Breathing',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              currentDestination = index;
            });
          },
          selectedIndex: currentDestination,
        ),
      ),
    );
  }
}
