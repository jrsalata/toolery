import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;

  @override
  void initState(){
    super.initState();
    _loadPrefs();
  }

  // all future persistent settings will be loaded
  // in through here
  // so every new option needs another line in the setState function
  // with a default value
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState((){
      darkMode = prefs.getBool('enableDarkMode') ?? true;
    });
  }

  // helper function to just change a single bool setting
  // note that for the change to reflect, the local value (like darkMode)
  // will need to be changed as well in the onChanged method
  Future<void> _changeBoolSetting(String setting, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState((){  
      prefs.setBool(setting, value);
    });
  }

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
                        _changeBoolSetting("enableDarkMode", value);
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
