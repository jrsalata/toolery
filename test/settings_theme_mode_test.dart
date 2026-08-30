import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolery/settings.dart';

/// Builds a notifier and waits for its async preference load to land.
Future<SettingsNotifier> loadedSettings() async {
  final settings = SettingsNotifier();
  await pumpEventQueue();
  return settings;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier themeMode', () {
    test('defaults to system when nothing has ever been stored', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = await loadedSettings();
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.darkMode, isFalse);
    });

    test('migrates a legacy enableDarkMode:true to dark', () async {
      SharedPreferences.setMockInitialValues({'enableDarkMode': true});
      final settings = await loadedSettings();
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.darkMode, isTrue);
    });

    test('migrates a legacy enableDarkMode:false to light', () async {
      SharedPreferences.setMockInitialValues({'enableDarkMode': false});
      final settings = await loadedSettings();
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.darkMode, isFalse);
    });

    test('the migration is persisted, so it only runs once', () async {
      SharedPreferences.setMockInitialValues({'enableDarkMode': true});
      await loadedSettings();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'dark');
    });

    test('an explicit themeMode wins over the legacy bool', () async {
      SharedPreferences.setMockInitialValues({
        'enableDarkMode': true,
        'themeMode': 'light',
      });
      final settings = await loadedSettings();
      expect(settings.themeMode, ThemeMode.light);
    });

    test('an unrecognised stored value falls back to system', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'chartreuse'});
      final settings = await loadedSettings();
      expect(settings.themeMode, ThemeMode.system);
    });

    test('changeThemeMode updates and persists the choice', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = await loadedSettings();

      settings.changeThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);

      await pumpEventQueue();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'dark');
    });
  });
}
