import 'package:flutter/material.dart';
import 'package:toolery/navigationbar.dart' show TooleryNavigationBar;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

    @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>{

  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Settings page')),
        body: Center(
          child: Column(
            children: [
              const Text("There will be settings here"),
              const Text("We will need to change things..."),
            ],
          ),
        ),
        bottomNavigationBar: TooleryNavigationBar(),
      ),
    );
  }
}