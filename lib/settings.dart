import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsNotifier with ChangeNotifier {
  bool darkMode = false;
  bool materialTheme = true;
  int customTheme = 0xFFFFFF00;

  SettingsNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('enableDarkMode') ?? true;
    materialTheme = prefs.getBool('useMaterialTheme') ?? true;
    customTheme = prefs.getInt('customThemeColor') ?? 0xFFFFFF00;
    notifyListeners();
  }

  Future<void> _setBoolPrefs(String setting, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(setting, value);
    notifyListeners();
  }

  Future<void> _setIntPrefs(String setting, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(setting, value);
    notifyListeners();
  }

  void changeDarkMode(bool value) {
    darkMode = value;
    _setBoolPrefs("enableDarkMode", value);
  }

  void changeMaterialTheme(bool value) {
    materialTheme = value;
    _setBoolPrefs("useMaterialTheme", value);
  }

  void changeCustomTheme(int value) {
    customTheme = value;
    _setIntPrefs("customThemeColor", value);
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings page')),
      body: Center(
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, child) => ListView(
            children: [
              Card(
                child: ListTile(
                  title: Text("Enable Dark mode?"),
                  trailing: Switch(
                    value: context.read<SettingsNotifier>().darkMode,
                    onChanged: ((bool value) {
                      context.read<SettingsNotifier>().changeDarkMode(value);
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
                      context.read<SettingsNotifier>().changeMaterialTheme(
                        value,
                      );
                    }),
                  ),
                ),
              ),
              if (!context.read<SettingsNotifier>().materialTheme)
                Card(
                  child: BlockPicker(
                    pickerColor: Color(
                      context.read<SettingsNotifier>().customTheme,
                    ),
                    onColorChanged: (changeColor) => context
                        .read<SettingsNotifier>()
                        .changeCustomTheme(changeColor.toARGB32()),
                  ),
                ),
              Card(
                child: ListTile(
                  title: Text("Set Custom Theme Color"),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  title: Text("Configure Tags"),
                  trailing: Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
