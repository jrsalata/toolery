import 'package:flutter/material.dart';

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
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Welcome to Toolery!')),
        body: Column(
          children: [
            const Text("This is a welcome page in"),
            const Text("We will see how this works!"),
          ],
        ),
        bottomNavigationBar: TooleryNavigationBar(),
      ),
    );
  }
}

class TooleryNavigationBar extends StatefulWidget {
  const TooleryNavigationBar({super.key});

  @override
  State<TooleryNavigationBar> createState() => _TooleryNavigationBarState();
}

class _TooleryNavigationBarState extends State<TooleryNavigationBar> {
  int currentDestination = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: "Menu 1"),
        NavigationDestination(icon: Icon(Icons.settings), label: "Settings")
      ],
      onDestinationSelected: (int index){
        setState((){
          currentDestination = index;
        });
      },
      selectedIndex: currentDestination,
    );
  }
}
