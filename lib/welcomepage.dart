import 'package:flutter/material.dart';

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
      ),
    );
  }
}

