import 'package:flutter/material.dart';
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
    );
  }
}

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
