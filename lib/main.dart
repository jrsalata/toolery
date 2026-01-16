// System imports
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/task.dart';

// Page imports
import 'package:toolery/settings.dart';
import 'package:toolery/welcomepage.dart';
import 'package:toolery/tasks.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
        ChangeNotifierProvider(create: (_) => TaskChangeNotifier()),
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
                  ? lightDynamic?.harmonized()
                  : ColorScheme.fromSeed(
                      seedColor: Color.fromRGBO(150, 10, 143, 1),
                    ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: settings.materialTheme
                  ? darkDynamic?.harmonized()
                  : ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                      brightness: Brightness.dark,
                    ),
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: child,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // NOTE: body and destinations must be in the same order to navigate
        body: [WelcomePage(), TaskPage(), SettingsPage()][currentDestination],
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Menu 1"),
            NavigationDestination(icon: Icon(Icons.task), label: "Tasks"),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: "Settings",
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
