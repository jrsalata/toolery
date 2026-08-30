import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a switch whichever platform rendered it.
///
/// As of Flutter 3.47 `Switch.adaptive` keeps the Material [Switch] widget on
/// iOS and restyles it through a `SwitchThemeData` adaptation rather than
/// substituting a [CupertinoSwitch], so `find.byType(Switch)` already matches
/// on both platforms. This finder also accepts a real [CupertinoSwitch] so
/// hand-written Cupertino branches — and any future change to `.adaptive` —
/// stay covered.
Finder findAdaptiveSwitch() =>
    find.byWidgetPredicate((w) => w is Switch || w is CupertinoSwitch);
