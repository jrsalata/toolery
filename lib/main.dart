import 'package:flutter/material.dart';
import 'package:toolery/navigationbar.dart';
import 'package:toolery/settings.dart';

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
        body: Center(
          child: Column(
            children: [
              const Text("This is a welcome page for Toolery!"),
              const Text("We will see how this works!"),
            ],
          ),
        ),
        bottomNavigationBar: TooleryNavigationBar(),
      ),
    );
  }
}

