// System imports
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

// Page imports
import 'package:toolery/settings.dart';
import 'package:toolery/welcomepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {


        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if(lightDynamic != null && darkDynamic != null){
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
          darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);
        }

        return MaterialApp(
          title: 'Toolery',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme
          ),
          themeMode: ThemeMode.system,
          home: const MainPage(),
        );
      }
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
    return Scaffold(

      // NOTE: body and destinations must be in the same order to navigate
      body: [WelcomePage(), SettingsPage()][currentDestination],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Menu 1"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentDestination = index;
          });
        },
        selectedIndex: currentDestination,
      ),
    );
  }
}
