import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Builds the seed colour scheme for the app.
///
/// When [useSystemAccent] is set the platform's own accent wins: Material You
/// colours harmonised from the wallpaper on Android, and the iOS system blue
/// on iOS. `dynamic_color` only ever reports a scheme on Android, so without
/// the iOS branch that preference would be a switch that does nothing.
ColorScheme appColorScheme({
  required bool useSystemAccent,
  required int customThemeColor,
  required ColorScheme? dynamicScheme,
  required Brightness brightness,
  required TargetPlatform platform,
}) {
  if (useSystemAccent) {
    if (dynamicScheme != null) return dynamicScheme.harmonized();
    if (platform == TargetPlatform.iOS) {
      return ColorScheme.fromSeed(
        seedColor: CupertinoColors.systemBlue,
        brightness: brightness,
      );
    }
  }
  return ColorScheme.fromSeed(
    seedColor: Color(customThemeColor),
    brightness: brightness,
  );
}

/// Corner radius used for cards and text fields on iOS, matching the
/// continuous-corner look of grouped inset lists.
const double _iosCornerRadius = 10;

/// Hairline width for iOS separators and the app bar's bottom rule.
const double _iosHairline = 0.5;

/// Builds the app's theme for [colorScheme], shaped for [platform].
///
/// Android gets plain Material 3. iOS keeps the same widget tree but reshapes
/// the pieces that read as Android — the app bar's tonal scroll-under, raised
/// cards, outlined text fields — so ~75 `Theme.of(context)` call sites follow
/// without being touched.
///
/// Setting [ThemeData.platform] is load-bearing: it drives typography, the
/// back chevron, scrollbars, `Icons.adaptive`, and every `.adaptive`
/// constructor. iOS system fonts can't be bundled, so there is deliberately no
/// hand-rolled SF Pro [TextTheme] here — Flutter resolves them already.
ThemeData buildAppTheme({
  required ColorScheme colorScheme,
  required TargetPlatform platform,
}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    platform: platform,
  );

  if (platform != TargetPlatform.iOS) return base;

  return base.copyWith(
    appBarTheme: AppBarThemeData(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(
          color: colorScheme.outlineVariant,
          width: _iosHairline,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_iosCornerRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_iosCornerRadius),
        borderSide: BorderSide.none,
      ),
    ),
    dividerTheme: const DividerThemeData(
      space: _iosHairline,
      thickness: _iosHairline,
    ),
  );
}
