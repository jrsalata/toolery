import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsNotifier with ChangeNotifier {
  static const int defaultCustomThemeColor = 0xFF673AB7;
  
  bool darkMode = false;
  bool materialTheme = true;
  int customTheme = defaultCustomThemeColor;

  SettingsNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('enableDarkMode') ?? true;
    materialTheme = prefs.getBool('useMaterialTheme') ?? true;
    customTheme = prefs.getInt('customThemeColor') ?? defaultCustomThemeColor;
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
                    value: settings.darkMode,
                    onChanged: ((bool value) {
                      settings.changeDarkMode(value);
                    }),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text("Use System Theme Color?"),
                  trailing: Switch(
                    value: settings.materialTheme,
                    onChanged: ((bool value) {
                      settings.changeMaterialTheme(
                        value,
                      );
                    }),
                  ),
                ),
              ),
              if (!settings.materialTheme)
                Card(
                  child: ListTile(
                    title: Text("Set Custom Theme Color"),
                    onTap: () async => showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext builder) => AlertDialog(
                        title: const Text("Select Color"),
                        content: BlockPicker(
                          pickerColor: Color(
                            settings.customTheme,
                          ),
                          onColorChanged: (changeColor) => settings.changeCustomTheme(changeColor.toARGB32()),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Done!"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
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
