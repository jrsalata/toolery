import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolery/accessibility/color_picker_dialog.dart';
import 'package:toolery/data/data_service.dart';
import 'package:toolery/forms/tag/main.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
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
    countUp = prefs.getBool('countUp') ?? true;
    breathingVibrate = prefs.getBool('breathingVibrate') ?? true;
    breathingSounds = prefs.getBool('breathingSounds') ?? true;
    returningUser = prefs.getBool('returningUser') ?? false;

    notifyListeners();
  }

  Future<void> _setBoolPrefs(String setting, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(setting, value);
    notifyListeners();
  }

  Future<void> _setIntPrefs(String setting, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(setting, value);
    notifyListeners();
  }

  void changeDarkMode(bool value) {
    darkMode = value;
    _setBoolPrefs('enableDarkMode', value);
  }

  void changeMaterialTheme(bool value) {
    materialTheme = value;
    _setBoolPrefs('useMaterialTheme', value);
  }

  void changeCountUp(bool value) {
    countUp = value;
    _setBoolPrefs('countUp', value);
  }

  void changeBreathingVibrate(bool value) {
    breathingVibrate = value;
    _setBoolPrefs('breathingVibrate', value);
  }

  void changeBreathingSounds(bool value) {
    breathingSounds = value;
    _setBoolPrefs('breathingSounds', value);
  }

  void changeCustomTheme(int value) {
    customTheme = value;
    _setIntPrefs('customThemeColor', value);
  }

  void changeReturningUser(bool value) {
    returningUser = value;
    _setBoolPrefs('returningUser', value);
  }
}

class SettingsPage extends StatelessWidget {
  final PackageInfo packageInfo;

  const SettingsPage({super.key, required this.packageInfo});

  Future<void> _exportData(BuildContext context) async {
    final String filePath;
    try {
      filePath = await DataService.exportData();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      return;
    }
    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], subject: 'Toolery Data Export'),
    );
  }

  Future<void> _importData(BuildContext context) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Import Data',
      message:
          'Importing will replace ALL current data with the contents of the '
          'selected ZIP file. This cannot be undone. Continue?',
      confirmLabel: 'Import',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final result = await DataService.importData();
    if (!context.mounted) return;

    if (result.cancelled) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Import failed.')),
      );
      return;
    }

    // Reload all notifiers so the UI reflects the newly imported data.
    await Future.wait([
      context.read<TaskNotifier>().loadAll(),
      context.read<TagNotifier>().loadAll(),
      context.read<BreathingNotifier>().loadAll(),
      context.read<AffirmationNotifier>().loadAll(),
    ]).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to reload data: $e')));
      }
      return [];
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data imported successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uri sourceCodeLink = Uri.parse('https://github.com/jrsalata/toolery');
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, child) => ListView(
            children: [
              Card(
                child: SwitchListTile(
                  title: const Text('Enable Dark mode?'),
                  value: settings.darkMode,
                  onChanged: ((bool value) {
                    settings.changeDarkMode(value);
                  }),
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text('Use System Theme Color?'),
                  value: settings.materialTheme,
                  onChanged: ((bool value) {
                    settings.changeMaterialTheme(value);
                  }),
                ),
              ),
              if (!settings.materialTheme)
                Card(
                  child: ListTile(
                    title: const Text('Set Custom Theme Color'),
                    onTap: () async => showAccessibleColorPickerDialog(
                      context: context,
                      pickerColor: Color(settings.customTheme),
                      onColorChanged: (changeColor) =>
                          settings.changeCustomTheme(changeColor.toARGB32()),
                    ),
                  ),
                ),
              Card(
                child: ListTile(
                  title: const Text('Configure Tags'),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TagPage()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Export Data'),
                  subtitle: const Text(
                    'Save all your data as a ZIP of CSV files',
                  ),
                  trailing: const Icon(Icons.upload),
                  onTap: () => _exportData(context),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Import Data'),
                  subtitle: const Text(
                    'Restore data from a previously exported ZIP file',
                  ),
                  trailing: const Icon(Icons.download),
                  onTap: () => _importData(context),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Source Code'),
                  subtitle: const Text('Users are welcome to contribute!'),
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
                  title: const Text('About'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: packageInfo.appName,
                    applicationVersion: packageInfo.version,
                    children: [
                      const Text('Created by John Salata'),
                      const Text('App icon created by Morgan Roberts'),
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
