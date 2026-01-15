import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier with ChangeNotifier {
  bool darkMode = false;
  bool materialTheme = true;
  String? customTheme;

  SettingsNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('enableDarkMode') ?? true;
    materialTheme = prefs.getBool('useMaterialTheme') ?? true;
    customTheme = prefs.getString('customThemeColor');
    notifyListeners();
  }

  void changeDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void changeMaterialTheme(bool value) {
    materialTheme = value;
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool materialTheme = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  // all future persistent settings will be loaded
  // in through here
  // so every new option needs another line in the setState function
  // with a default value
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('enableDarkMode') ?? true;
      materialTheme = prefs.getBool('useMaterialTheme') ?? true;
    });
  }

  // helper function to just change a single bool setting
  // note that for the change to reflect, the local value (like darkMode)
  // will need to be changed as well in the onChanged method
  Future<void> _changeBoolSetting(String setting, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(setting, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings page')),
      body: Center(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text("Enable Dark mode?"),
                trailing: Switch(
                  value: context.read<SettingsNotifier>().darkMode,
                  onChanged: ((bool value) {
                    setState(() {
                      context.read<SettingsNotifier>().changeDarkMode(value);
                      _changeBoolSetting("enableDarkMode", value);
                    });
                  }),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Use System Theme Color?"),
                trailing: Switch(
                  value: context.read<SettingsNotifier>().materialTheme,
                  onChanged: ((bool value) {
                    setState(() {
                      context.read<SettingsNotifier>().changeMaterialTheme(value);
                      _changeBoolSetting("useMaterialTheme", value);
                    });
                  }),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Configure Tags"),
                trailing: Icon(Icons.more_vert),
              )
            )
          ],
        ),
      ),
    );
  }
}