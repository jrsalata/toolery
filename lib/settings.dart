import 'package:flutter/cupertino.dart'
    show
        CupertinoAlertDialog,
        CupertinoDialogAction,
        CupertinoSlidingSegmentedControl;
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
import 'package:toolery/widgets/adaptive/platform.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Manages and persists the user's application preferences.
///
/// Settings are stored via [SharedPreferences] and loaded automatically when
/// the notifier is created. Widgets can listen for changes via
/// `context.watch<SettingsNotifier>()`.
///
/// **Available preferences**
/// - [themeMode] – follow the system appearance, or force light/dark.
/// - [materialTheme] – use the platform's own accent as the seed colour
///   instead of [customTheme]: dynamic Material You colours from the wallpaper
///   on Android, the iOS system blue on iOS.
/// - [countUp] – breathing exercise timer counts up from 0 (when `true`) or
///   down from the phase duration (when `false`).
/// - [breathingVibrate] – trigger haptic feedback at the start of each phase.
/// - [breathingSounds] – play audio cues at the start of each phase.
/// - [returningUser] – skip the first-launch intro dialogs.
/// - [customTheme] – ARGB colour integer used as the seed for the app's colour
///   scheme when [materialTheme] is `false`.
class SettingsNotifier with ChangeNotifier {
  static const int defaultCustomThemeColor = 0xFF673AB7;

  ThemeMode themeMode = ThemeMode.system;
  bool materialTheme = true;

  /// Kept so existing callers and tests that only care about "is it dark"
  /// keep working after the move to a three-way [themeMode].
  bool get darkMode => themeMode == ThemeMode.dark;
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
    themeMode = await _loadThemeMode(prefs);
    materialTheme = prefs.getBool('useMaterialTheme') ?? true;
    customTheme = prefs.getInt('customThemeColor') ?? defaultCustomThemeColor;
    countUp = prefs.getBool('countUp') ?? true;
    breathingVibrate = prefs.getBool('breathingVibrate') ?? true;
    breathingSounds = prefs.getBool('breathingSounds') ?? true;
    returningUser = prefs.getBool('returningUser') ?? false;

    notifyListeners();
  }

  /// Reads [themeMode], migrating once from the legacy `enableDarkMode` bool.
  ///
  /// A user who never expressed a preference lands on [ThemeMode.system],
  /// which is what iOS users expect; one who did keeps the mode they chose.
  Future<ThemeMode> _loadThemeMode(SharedPreferences prefs) async {
    final stored = prefs.getString('themeMode');
    if (stored != null) {
      return ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    }
    final legacy = prefs.getBool('enableDarkMode');
    if (legacy == null) return ThemeMode.system;
    final migrated = legacy ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString('themeMode', migrated.name);
    return migrated;
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

  Future<void> _setStringPrefs(String setting, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(setting, value);
    notifyListeners();
  }

  void changeThemeMode(ThemeMode value) {
    themeMode = value;
    _setStringPrefs('themeMode', value.name);
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

  static const List<String> _credits = [
    'Created by John Salata',
    'App icon created by Morgan Roberts',
  ];

  /// Shows the about box.
  ///
  /// Deliberately not showAdaptiveAboutDialog: on iOS that packs the name,
  /// version, legalese *and* children into CupertinoAlertDialog's scrollable
  /// content area, which clips. The credits ended up laid out below the fold
  /// with no visible affordance, so they simply read as missing. iOS gets a
  /// compact dialog laid out here instead; Android keeps the stock one, which
  /// was already correct.
  void _showAbout(BuildContext context) {
    if (!isCupertino(context)) {
      showAboutDialog(
        context: context,
        applicationName: packageInfo.appName,
        applicationVersion: packageInfo.version,
        children: [for (final line in _credits) Text(line)],
      );
      return;
    }

    showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(packageInfo.appName),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Version ${packageInfo.version}'),
              const SizedBox(height: 8),
              for (final line in _credits) Text(line),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => showLicensePage(
              context: dialogContext,
              applicationName: packageInfo.appName,
              applicationVersion: packageInfo.version,
            ),
            child: const Text('View Licenses'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
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
              Card(child: _ThemeModeTile(settings: settings)),
              Card(
                child: SwitchListTile.adaptive(
                  title: Text(
                    isCupertino(context)
                        ? 'Use iOS accent colour?'
                        : 'Use System Theme Color?',
                  ),
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
                  trailing: Icon(Icons.adaptive.more),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TagPage()),
                  ),
                ),
              ),
              const Card(child: _ExportDataTile()),
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
                  onTap: () => _showAbout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three-way Light / Dark / System appearance picker.
///
/// One of the few places a genuine platform branch earns its keep: iOS has a
/// sliding segmented control with no Material equivalent, and vice versa.
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.settings});

  final SettingsNotifier settings;

  static const Map<ThemeMode, String> _labels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Appearance'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: isCupertino(context)
              ? CupertinoSlidingSegmentedControl<ThemeMode>(
                  groupValue: settings.themeMode,
                  children: {
                    for (final entry in _labels.entries)
                      entry.key: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(entry.value),
                      ),
                  },
                  onValueChanged: (mode) {
                    if (mode != null) settings.changeThemeMode(mode);
                  },
                )
              : SegmentedButton<ThemeMode>(
                  segments: [
                    for (final entry in _labels.entries)
                      ButtonSegment<ThemeMode>(
                        value: entry.key,
                        label: Text(entry.value),
                      ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      settings.changeThemeMode(selection.first),
                ),
        ),
      ),
    );
  }
}

class _ExportDataTile extends StatelessWidget {
  const _ExportDataTile();

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
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'Toolery Data Export',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Export Data'),
      subtitle: const Text('Save all your data as a ZIP of CSV files'),
      trailing: const Icon(Icons.upload),
      onTap: () => _exportData(context),
    );
  }
}
