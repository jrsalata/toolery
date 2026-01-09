import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Settings page')),
        body: Center(
          child: Column(
            children: [
              const Text("There will be settings here"),
              const Text("We will need to change things..."),
              Row(
                children: [
                  const Text("Enable Dark Mode?"),
                  Switch(
                    value: darkMode,
                    onChanged: ((bool value) {
                      setState(() {
                        darkMode = value;
                      });
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
