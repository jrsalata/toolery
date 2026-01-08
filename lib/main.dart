import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

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
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Toolery!')
        ),
        body: Column(children: 
          [
            const Text("This is a demonstration"),
            const Text("We will see how this works!"),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled, semanticLabel: "Test Icon"), 
              label: "Test Label"),
            BottomNavigationBarItem(
              icon: Icon(Icons.twenty_two_mp_sharp, semanticLabel: "Test2 Icon"),
              label: "Test 2 Label"),
            
          ],
        ),
      )
    );
  }
}
