import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:toolery/forms/tag/main.dart';
import 'package:url_launcher/url_launcher.dart';

/// Manages and persists the user's application preferences.
///
/// Settings are stored via [SharedPreferences] and loaded automatically when
/// the notifier is created. Widgets can listen for changes via
/// `context.watch<SettingsNotifier>()`.
///
/// **Available preferences**
/// - [darkMode] – use the dark colour scheme.
/// - [materialTheme] – use dynamic Material You colours derived from the
///   device wallpaper instead of [customTheme].
/// - [countUp] – breathing exercise timer counts up from 0 (when `true`) or
///   down from the phase duration (when `false`).
/// - [breathingVibrate] – trigger haptic feedback at the start of each phase.
/// - [breathingSounds] – play audio cues at the start of each phase.
/// - [returningUser] – skip the first-launch intro dialogs.
/// - [customTheme] – ARGB colour integer used as the seed for the app's colour
///   scheme when [materialTheme] is `false`.
class SettingsNotifier with ChangeNotifier {
  static const int defaultCustomThemeColor = 0xFF673AB7;

  bool darkMode = false;
  bool materialTheme = true;
  bool countUp = true;
  bool breathingVibrate = true;
  bool breathingSounds = true;
  bool returningUser = true;
  int customTheme = defaultCustomThemeColor;

  SettingsNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('enableDarkMode') ?? true;
    materialTheme = prefs.getBool('useMaterialTheme') ?? true;
    customTheme = prefs.getInt('customThemeColor') ?? defaultCustomThemeColor;
    countUp = prefs.getBool("countUp") ?? true;
    breathingVibrate = prefs.getBool("breathingVibrate") ?? true;
    breathingSounds = prefs.getBool("breathingSounds") ?? true;
    returningUser = prefs.getBool('returningUser') ?? false;

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

  void changeCountUp(bool value) {
    countUp = value;
    _setBoolPrefs("countUp", value);
  }

  void changeBreathingVibrate(bool value) {
    breathingVibrate = value;
    _setBoolPrefs("breathingVibrate", value);
  }

  void changeBreathingSounds(bool value) {
    breathingSounds = value;
    _setBoolPrefs("breathingSounds", value);
  }

  void changeCustomTheme(int value) {
    customTheme = value;
    _setIntPrefs("customThemeColor", value);
  }

  void changeReturningUser(bool value) {
    returningUser = value;
    _setBoolPrefs("returningUser", value);
  }
}

class SettingsPage extends StatelessWidget {
  final PackageInfo packageInfo;

  const SettingsPage({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    final Uri sourceCodeLink = Uri.parse("https://github.com/jrsalata/toolery");
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, child) => ListView(
            children: [
              Card(
                child: ListTile(
                  title: const Text("Enable Dark mode?"),
                  trailing: Semantics(
                    label: 'Enable dark mode',
                    toggled: settings.darkMode,
                    child: Switch(
                      value: settings.darkMode,
                      onChanged: ((bool value) {
                        settings.changeDarkMode(value);
                      }),
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Use System Theme Color?"),
                  trailing: Semantics(
                    label: 'Use system theme color',
                    toggled: settings.materialTheme,
                    child: Switch(
                      value: settings.materialTheme,
                      onChanged: ((bool value) {
                        settings.changeMaterialTheme(value);
                      }),
                    ),
                  ),
                ),
              ),
              if (!settings.materialTheme)
                Card(
                  child: ListTile(
                    title: const Text("Set Custom Theme Color"),
                    onTap: () async => showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext builder) => AlertDialog(
                        title: const Text("Select Color"),
                        content: BlockPicker(
                          pickerColor: Color(settings.customTheme),
                          onColorChanged: (changeColor) => settings
                              .changeCustomTheme(changeColor.toARGB32()),
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
                  title: const Text("Configure Tags"),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TagPage()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Source Code"),
                  subtitle: const Text("Users are welcome to contribute!"),
                  onTap: () async {
                    final launched = await launchUrl(sourceCodeLink);
                    if (!launched) {
                      debugPrint('Could not launch $sourceCodeLink');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open source code link.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text("About"),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: packageInfo.appName,
                    applicationVersion: packageInfo.version,
                    children: [
                      Text("Created by John Salata"),
                      Text("App icon created by Morgan Roberts"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
